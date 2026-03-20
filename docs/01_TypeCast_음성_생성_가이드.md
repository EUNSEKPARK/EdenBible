# TypeCast 음성 생성 가이드

**문서 버전:** v1.0  
**작성일:** 2026-03-19  
**목적:** 성경 66권 전체 음원을 TypeCast API로 생성하는 절차 및 스크립트 정리

---

## 1. TypeCast API 핵심 제약 사항

| 항목 | 값 |
|------|------|
| **1회 요청 최대 글자 수** | **2,000자** |
| API 엔드포인트 | `POST https://api.typecast.ai/v1/text-to-speech` |
| 인증 | `X-API-KEY` 헤더 |
| 최신 모델 | `ssfm-v30` (권장) |
| 출력 포맷 | WAV (44.1kHz, 16bit, 모노) / MP3 (320kbps) |
| 감정 프리셋 | normal, happy, sad, angry, whisper, toneup, tonedown |
| 한국어 코드 | `KOR` |
| 과금 | 텍스트 글자 수 + 다운로드 시간 기준 |

> **핵심:** 성경 1장의 평균 글자 수는 약 800~3,000자. 2,000자를 초과하는 장은 **분할 요청 후 오디오 병합**이 필요합니다.

---

## 2. 성경 데이터 글자 수 분석

### 2-1. 장별 글자 수 분포 (bible_full.json 기준)

| 구간 | 장 수 (추정) | 비율 | 처리 방식 |
|------|------------|------|----------|
| 0~1,000자 | ~400장 | 34% | 1회 요청으로 완료 |
| 1,001~2,000자 | ~500장 | 42% | 1회 요청으로 완료 |
| 2,001~3,000자 | ~200장 | 17% | 2회 분할 |
| 3,001~4,000자 | ~70장 | 6% | 2회 분할 |
| 4,001자 이상 | ~19장 | 1% | 3회 이상 분할 |
| **합계** | **1,189장** | 100% | |

> 약 76%의 장은 1회 요청으로 처리 가능, 나머지 24%만 분할 필요.

### 2-2. 분할 전략

**절(verse) 단위로 분할**하여 2,000자를 초과하지 않도록 합니다.

```
장의 전체 텍스트 = 절1 + 절2 + 절3 + ... + 절N

chunk_1 = 절1 + 절2 + ... + 절K  (합계 ≤ 2,000자)
chunk_2 = 절K+1 + ... + 절M      (합계 ≤ 2,000자)
chunk_3 = 절M+1 + ... + 절N      (합계 ≤ 2,000자)

→ 각 chunk를 TypeCast API로 생성
→ ffmpeg로 chunk 오디오를 순서대로 병합
→ 최종 1개 파일 = 해당 장의 완성 음원
```

---

## 3. 사전 준비

### 3-1. TypeCast API 키 발급

1. https://typecast.ai/developers 접속
2. 회원가입 / 로그인
3. API Key 생성 → 복사
4. 환경 변수에 저장:
   ```bash
   export TYPECAST_API_KEY='your_api_key_here'
   ```

### 3-2. 캐릭터(Voice) 선택

성경 낭독에 적합한 캐릭터를 미리 선택합니다.

**추천 기준:**
- 성별: 남성 (전통적 성경 낭독 톤) 또는 여성 (부드러운 톤)
- 연령: 중년 (adult)
- 사용 사례: Audiobook/Storytelling
- 감정: normal (기본) + smart emotion (문맥 자동 감지)

**캐릭터 목록 조회:**
```bash
curl -s https://api.typecast.ai/v2/voices \
  -H "X-API-KEY: $TYPECAST_API_KEY" \
  -G -d "model=ssfm-v30" -d "language=kor" \
  | python3 -m json.tool
```

조회 후 원하는 voice_id를 기록합니다 (예: `tc_xxxxxxxxxxxxxxxxxxxx`).

### 3-3. 필수 도구 설치

```bash
# Python 패키지
pip install requests pydub

# ffmpeg (오디오 병합용)
# macOS
brew install ffmpeg

# Ubuntu
sudo apt install ffmpeg
```

### 3-4. 요금제 확인

| 플랜 | 다운로드 크레딧 | 월 비용 | 비고 |
|------|--------------|--------|------|
| Free | 5분/월 | $0 | 체험용, 워터마크 |
| Basic | 60분/월 | ~$10 | 기본 |
| Pro | 2시간/월 | ~$30 | 워터마크 없음 |
| Business | 6시간/월 | ~$90 | 대량 생성 |

> 성경 전체 ~80시간이므로 Business 플랜으로 약 **14개월** 또는 추가 크레딧 구매 필요.
> 파일럿(18장, ~1시간)은 Pro 플랜 1개월로 충분.

---

## 4. 생성 스크립트 (Python)

### 4-1. 메인 스크립트: `generate_bible_audio.py`

```python
#!/usr/bin/env python3
"""
에덴 성경책 — TypeCast 음성 생성 스크립트
성경 bible_full.json에서 장별 텍스트를 추출하여
TypeCast API로 음원을 생성합니다.

사용법:
  python generate_bible_audio.py --book 1 --chapter 1
  python generate_bible_audio.py --book 1 --start-chapter 1 --end-chapter 3
  python generate_bible_audio.py --all --output-dir ./output/audio
"""

import os
import sys
import json
import time
import argparse
import requests
from pathlib import Path
from pydub import AudioSegment
import io

# ─── 설정 ───
API_KEY = os.environ.get("TYPECAST_API_KEY", "")
API_URL = "https://api.typecast.ai/v1/text-to-speech"
MODEL = "ssfm-v30"
LANGUAGE = "KOR"
VOICE_ID = os.environ.get("TYPECAST_VOICE_ID", "tc_60e5426de8b95f1d3000d7b5")  # 기본값, 실제 사용 시 변경
MAX_CHARS = 2000       # TypeCast 1회 요청 최대 글자 수
CHUNK_TARGET = 1800    # 안전 마진을 둔 목표 글자 수
OUTPUT_FORMAT = "wav"  # wav 또는 mp3
RATE_LIMIT_DELAY = 2   # API 호출 간 대기 시간 (초)

# ─── 감정 설정 ───
# 성경 낭독에 적합한 기본 감정
DEFAULT_EMOTION = {
    "emotion_type": "smart",
    "previous_text": "",
    "next_text": ""
}


def load_bible_data(bible_path: str) -> dict:
    """bible_full.json 로드"""
    with open(bible_path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_books_index(index_path: str) -> list:
    """books_index.json 로드"""
    with open(index_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        return data["books"]


def get_chapter_text(bible_data: dict, book_id: int, chapter: int) -> list[dict]:
    """특정 장의 모든 절 텍스트를 반환 [{verse: int, text: str}, ...]"""
    books = bible_data["books"]
    book = next((b for b in books if b["id"] == book_id), None)
    if not book:
        raise ValueError(f"Book ID {book_id} not found")
    
    chapters = book["chapters"]
    if chapter < 1 or chapter > len(chapters):
        raise ValueError(f"Chapter {chapter} not found in book {book_id}")
    
    chapter_data = chapters[chapter - 1]
    verses = []
    for v in chapter_data["verses"]:
        text = clean_text(v.get("krv", ""))
        if text:
            verses.append({"verse": v["verse"], "text": text})
    return verses


def clean_text(text: str) -> str:
    """HTML 엔티티 및 특수문자 정리"""
    replacements = {
        "&#x27;": "'", "&#39;": "'", "&apos;": "'",
        "&#x22;": '"', "&quot;": '"',
        "&amp;": "&", "&lt;": "<", "&gt;": ">", "&nbsp;": " "
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text.strip()


def split_into_chunks(verses: list[dict], max_chars: int = CHUNK_TARGET) -> list[list[dict]]:
    """
    절 목록을 2,000자 이하 청크로 분할.
    절 단위로만 분할하여 문장이 잘리지 않도록 보장.
    """
    chunks = []
    current_chunk = []
    current_length = 0

    for verse in verses:
        verse_text = f"{verse['verse']}절 {verse['text']} "
        verse_length = len(verse_text)

        # 단일 절이 max_chars를 초과하는 극단적 케이스
        if verse_length > max_chars:
            # 현재 청크 저장
            if current_chunk:
                chunks.append(current_chunk)
                current_chunk = []
                current_length = 0
            # 긴 절은 단독 청크로 (추후 문장 단위 분할 가능)
            chunks.append([verse])
            continue

        # 현재 청크에 추가 시 초과하면 새 청크 시작
        if current_length + verse_length > max_chars:
            chunks.append(current_chunk)
            current_chunk = []
            current_length = 0

        current_chunk.append(verse)
        current_length += verse_length

    # 마지막 청크 저장
    if current_chunk:
        chunks.append(current_chunk)

    return chunks


def chunk_to_text(chunk: list[dict]) -> str:
    """청크의 절 목록을 하나의 텍스트로 결합"""
    # 절 번호 없이 본문만 연결 (더 자연스러운 낭독)
    return " ".join(v["text"] for v in chunk)


def generate_audio(text: str, prev_text: str = "", next_text: str = "") -> bytes | None:
    """TypeCast API로 음성 생성, WAV 바이너리 반환"""
    if not API_KEY:
        print("ERROR: TYPECAST_API_KEY 환경 변수가 설정되지 않았습니다.")
        sys.exit(1)

    headers = {
        "X-API-KEY": API_KEY,
        "Content-Type": "application/json"
    }

    payload = {
        "voice_id": VOICE_ID,
        "text": text,
        "model": MODEL,
        "language": LANGUAGE,
        "prompt": {
            "emotion_type": "smart",
            "previous_text": prev_text[:500] if prev_text else "",
            "next_text": next_text[:500] if next_text else ""
        },
        "output": {
            "volume": 100,
            "audio_pitch": 0,
            "audio_tempo": 1.0,
            "audio_format": OUTPUT_FORMAT
        }
    }

    try:
        response = requests.post(API_URL, headers=headers, json=payload, timeout=120)
        
        if response.status_code == 200:
            return response.content
        elif response.status_code == 429:
            print("  ⏳ Rate limit 도달, 30초 대기...")
            time.sleep(30)
            return generate_audio(text, prev_text, next_text)  # 재시도
        else:
            print(f"  ❌ API 오류 {response.status_code}: {response.text[:200]}")
            return None
    except requests.exceptions.Timeout:
        print("  ⏳ 요청 타임아웃, 10초 후 재시도...")
        time.sleep(10)
        return generate_audio(text, prev_text, next_text)
    except Exception as e:
        print(f"  ❌ 요청 실패: {e}")
        return None


def merge_audio_chunks(audio_chunks: list[bytes], output_path: str):
    """여러 WAV/MP3 청크를 하나의 파일로 병합"""
    if len(audio_chunks) == 1:
        with open(output_path, "wb") as f:
            f.write(audio_chunks[0])
        return

    combined = AudioSegment.empty()
    silence = AudioSegment.silent(duration=300)  # 청크 사이 0.3초 무음

    for i, chunk_data in enumerate(audio_chunks):
        segment = AudioSegment.from_file(io.BytesIO(chunk_data), format=OUTPUT_FORMAT)
        if i > 0:
            combined += silence
        combined += segment

    # 출력 포맷에 따라 저장
    if output_path.endswith(".mp3"):
        combined.export(output_path, format="mp3", bitrate="128k")
    elif output_path.endswith(".opus"):
        combined.export(output_path, format="opus", bitrate="48k")
    else:
        combined.export(output_path, format="wav")


def generate_chapter(bible_data: dict, book_id: int, chapter: int, 
                     output_dir: str, books_index: list) -> bool:
    """하나의 장에 대한 음원 생성"""
    book_info = next((b for b in books_index if b["id"] == book_id), None)
    book_name = book_info["name_ko"] if book_info else f"Book{book_id}"
    
    # 출력 파일명: 01_001.wav (book_chapter)
    filename = f"{book_id:02d}_{chapter:03d}.{OUTPUT_FORMAT}"
    output_path = os.path.join(output_dir, filename)

    # 이미 생성된 파일 스킵
    if os.path.exists(output_path):
        print(f"  ⏭ {book_name} {chapter}장 — 이미 존재, 스킵")
        return True

    # 장 텍스트 추출
    verses = get_chapter_text(bible_data, book_id, chapter)
    if not verses:
        print(f"  ⚠ {book_name} {chapter}장 — 절 데이터 없음, 스킵")
        return False

    full_text = " ".join(v["text"] for v in verses)
    total_chars = len(full_text)

    # 청크 분할
    chunks = split_into_chunks(verses)
    num_chunks = len(chunks)

    print(f"  📖 {book_name} {chapter}장 — {len(verses)}절, {total_chars}자, {num_chunks}청크")

    # 각 청크별 음성 생성
    audio_chunks = []
    for i, chunk in enumerate(chunks):
        text = chunk_to_text(chunk)
        
        # Smart Emotion을 위한 이전/다음 텍스트
        prev_text = chunk_to_text(chunks[i - 1]) if i > 0 else ""
        next_text = chunk_to_text(chunks[i + 1]) if i < num_chunks - 1 else ""

        print(f"    청크 {i + 1}/{num_chunks}: {len(text)}자 ", end="")

        audio_data = generate_audio(text, prev_text, next_text)
        if audio_data:
            audio_chunks.append(audio_data)
            print("✅")
        else:
            print("❌")
            return False

        # Rate limit 방지
        if i < num_chunks - 1:
            time.sleep(RATE_LIMIT_DELAY)

    # 청크 병합 및 저장
    merge_audio_chunks(audio_chunks, output_path)
    file_size = os.path.getsize(output_path) / 1024 / 1024
    print(f"    → 저장: {filename} ({file_size:.1f}MB)")
    return True


def main():
    parser = argparse.ArgumentParser(description="에덴 성경책 TypeCast 음성 생성기")
    parser.add_argument("--bible", default="assets/data/bible_full.json", help="bible_full.json 경로")
    parser.add_argument("--index", default="assets/data/books_index.json", help="books_index.json 경로")
    parser.add_argument("--output-dir", default="./output/audio", help="출력 디렉토리")
    parser.add_argument("--book", type=int, help="특정 책 ID (1~66)")
    parser.add_argument("--chapter", type=int, help="특정 장 번호")
    parser.add_argument("--start-chapter", type=int, default=1, help="시작 장")
    parser.add_argument("--end-chapter", type=int, help="종료 장")
    parser.add_argument("--all", action="store_true", help="전체 성경 생성")
    parser.add_argument("--format", default="wav", choices=["wav", "mp3"], help="출력 포맷")
    parser.add_argument("--voice", help="TypeCast Voice ID (기본: 환경변수 TYPECAST_VOICE_ID)")
    args = parser.parse_args()

    global OUTPUT_FORMAT, VOICE_ID
    OUTPUT_FORMAT = args.format
    if args.voice:
        VOICE_ID = args.voice

    # 데이터 로드
    bible_data = load_bible_data(args.bible)
    books_index = load_books_index(args.index)

    # 출력 디렉토리 생성
    os.makedirs(args.output_dir, exist_ok=True)

    # 생성 대상 결정
    if args.all:
        targets = [(b["id"], ch) for b in books_index 
                   for ch in range(1, b["chapter_count"] + 1)]
    elif args.book and args.chapter:
        targets = [(args.book, args.chapter)]
    elif args.book:
        book = next(b for b in books_index if b["id"] == args.book)
        end_ch = args.end_chapter or book["chapter_count"]
        targets = [(args.book, ch) for ch in range(args.start_chapter, end_ch + 1)]
    else:
        print("사용법: --book N --chapter M  또는  --book N  또는  --all")
        sys.exit(1)

    # 생성 시작
    total = len(targets)
    success = 0
    failed = 0

    print(f"\n🎙 에덴 성경책 음성 생성 시작")
    print(f"   대상: {total}장")
    print(f"   모델: {MODEL}")
    print(f"   포맷: {OUTPUT_FORMAT}")
    print(f"   Voice: {VOICE_ID}")
    print(f"   출력: {args.output_dir}")
    print(f"{'='*50}\n")

    for i, (book_id, chapter) in enumerate(targets):
        print(f"[{i + 1}/{total}]", end="")
        ok = generate_chapter(bible_data, book_id, chapter, args.output_dir, books_index)
        if ok:
            success += 1
        else:
            failed += 1
        
        # 장 사이 대기
        if i < total - 1:
            time.sleep(RATE_LIMIT_DELAY)

    print(f"\n{'='*50}")
    print(f"✅ 완료: {success}장 성공, ❌ {failed}장 실패")
    print(f"📁 출력: {args.output_dir}")


if __name__ == "__main__":
    main()
```

### 4-2. 글자 수 사전 분석 스크립트: `analyze_bible_chars.py`

```python
#!/usr/bin/env python3
"""
성경 장별 글자 수를 분석하여 분할이 필요한 장을 미리 파악합니다.

사용법:
  python analyze_bible_chars.py --bible assets/data/bible_full.json
"""

import json
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bible", default="assets/data/bible_full.json")
    parser.add_argument("--index", default="assets/data/books_index.json")
    parser.add_argument("--limit", type=int, default=2000, help="글자 수 제한")
    args = parser.parse_args()

    with open(args.bible, "r", encoding="utf-8") as f:
        bible = json.load(f)
    with open(args.index, "r", encoding="utf-8") as f:
        index = json.load(f)["books"]

    total_chapters = 0
    over_limit = 0
    char_distribution = {
        "0~500": 0, "501~1000": 0, "1001~1500": 0,
        "1501~2000": 0, "2001~3000": 0, "3001~4000": 0, "4001+": 0
    }
    longest_chapters = []

    for book in bible["books"]:
        book_info = next((b for b in index if b["id"] == book["id"]), {})
        book_name = book_info.get("name_ko", f"Book{book['id']}")

        for ch_idx, chapter in enumerate(book["chapters"]):
            ch_num = ch_idx + 1
            total_chapters += 1
            
            text = " ".join(v.get("krv", "") for v in chapter["verses"])
            char_count = len(text)

            # 분포 집계
            if char_count <= 500: char_distribution["0~500"] += 1
            elif char_count <= 1000: char_distribution["501~1000"] += 1
            elif char_count <= 1500: char_distribution["1001~1500"] += 1
            elif char_count <= 2000: char_distribution["1501~2000"] += 1
            elif char_count <= 3000: char_distribution["2001~3000"] += 1
            elif char_count <= 4000: char_distribution["3001~4000"] += 1
            else: char_distribution["4001+"] += 1

            if char_count > args.limit:
                over_limit += 1
                chunks_needed = (char_count // 1800) + 1
                longest_chapters.append((book_name, ch_num, char_count, chunks_needed))

    # 결과 출력
    print(f"\n📊 성경 글자 수 분석 (제한: {args.limit}자)")
    print(f"{'='*50}")
    print(f"총 장 수: {total_chapters}")
    print(f"2,000자 이하 (1회 요청): {total_chapters - over_limit}장 ({(total_chapters - over_limit)/total_chapters*100:.1f}%)")
    print(f"2,000자 초과 (분할 필요): {over_limit}장 ({over_limit/total_chapters*100:.1f}%)")
    
    print(f"\n📈 글자 수 분포:")
    for range_str, count in char_distribution.items():
        bar = "█" * (count // 10)
        print(f"  {range_str:>12}: {count:>4}장 {bar}")

    if longest_chapters:
        longest_chapters.sort(key=lambda x: -x[2])
        print(f"\n🔴 분할 필요 장 (상위 20개):")
        print(f"  {'책':>12} {'장':>4} {'글자수':>6} {'청크수':>5}")
        print(f"  {'-'*35}")
        for name, ch, chars, chunks in longest_chapters[:20]:
            print(f"  {name:>12} {ch:>4} {chars:>6} {chunks:>5}")

    # API 호출 횟수 추정
    total_api_calls = (total_chapters - over_limit) + sum(c[3] for c in longest_chapters)
    print(f"\n📞 예상 총 API 호출 횟수: ~{total_api_calls}회")
    print(f"⏱ 예상 소요 시간: ~{total_api_calls * 3 / 3600:.1f}시간 (호출당 ~3초)")


if __name__ == "__main__":
    main()
```

---

## 5. 실행 예시

### 5-1. 글자 수 분석 먼저 실행

```bash
cd /path/to/EdenBible
python scripts/analyze_bible_chars.py --bible assets/data/bible_full.json
```

### 5-2. 파일럿 생성 (창세기 1~3장)

```bash
export TYPECAST_API_KEY='your_key'
export TYPECAST_VOICE_ID='tc_xxxxxxxxxxxxxxxxxxxx'

python scripts/generate_bible_audio.py \
  --book 1 \
  --start-chapter 1 \
  --end-chapter 3 \
  --format wav \
  --output-dir ./output/audio
```

### 5-3. 특정 책 전체 생성 (시편)

```bash
python scripts/generate_bible_audio.py \
  --book 19 \
  --format wav \
  --output-dir ./output/audio
```

### 5-4. 전체 성경 생성

```bash
# 전체 생성 (주의: 수 시간~수 일 소요)
python scripts/generate_bible_audio.py \
  --all \
  --format wav \
  --output-dir ./output/audio
```

### 5-5. 생성 후 Opus 변환 (용량 최적화)

```bash
# WAV → Opus 48kbps 일괄 변환
for f in output/audio/*.wav; do
  ffmpeg -i "$f" -c:a libopus -b:a 48k "${f%.wav}.opus"
done
```

---

## 6. 성경 낭독에 추천하는 캐릭터 설정

### 6-1. 감정 설정 가이드

| 성경 구분 | 추천 감정 | 설명 |
|---------|----------|------|
| 역사서 (창세기, 열왕기 등) | `smart` | 문맥에 따라 자동 감지 |
| 시편 | `smart` 또는 수동 | 찬양=happy, 탄식=sad |
| 잠언 / 전도서 | `normal` | 차분한 교훈 톤 |
| 선지서 (이사야, 예레미야) | `smart` | 위로=soft, 경고=toneup |
| 복음서 | `smart` | 대화 장면 자동 감지 |
| 서신서 (로마서, 고린도서) | `normal` | 논리적 해설 톤 |
| 요한계시록 | `smart` | 극적 장면 자동 감지 |

### 6-2. 속도/피치 추천

```json
{
  "output": {
    "volume": 100,
    "audio_pitch": 0,
    "audio_tempo": 0.95,
    "audio_format": "wav"
  }
}
```

> `audio_tempo: 0.95` — 일반 속도보다 약간 느리게 설정하면 성경 낭독에 적합한 경건한 속도감을 줍니다.

---

## 7. 비용 추정

| 항목 | 수치 |
|------|------|
| 성경 전체 글자 수 | ~150만 자 (추정) |
| 예상 음원 총 시간 | ~80시간 |
| Business 플랜 월 크레딧 | 6시간 |
| 필요 개월 수 | ~14개월 |
| 추가 크레딧 구매 시 | 비용 별도 확인 |
| 파일럿 (18장) 비용 | Pro 1개월 (~$30) |

---

## 8. 주의사항

1. **API Rate Limit:** 과도한 요청 시 429 에러 발생. 스크립트에 자동 대기 로직이 포함되어 있음
2. **이어받기:** 스크립트가 이미 존재하는 파일은 자동 스킵하므로, 중단 후 재시작 가능
3. **상업적 사용:** Pro 이상 플랜에서 상업적 사용 가능. 무료 플랜은 워터마크 포함
4. **음질 검수:** 생성 후 반드시 샘플 청취 검수. 이상한 발음이나 끊김이 있으면 해당 장만 재생성
5. **성경 고유명사:** 히브리어/그리스어 고유명사 발음이 부자연스러울 수 있음. TypeCast의 발음 교정 기능 활용 권장

---

**문서 끝 | 프로젝트 에덴 · TypeCast 음성 생성 가이드 v1.0**