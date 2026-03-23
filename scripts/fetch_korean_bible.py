#!/usr/bin/env python3
"""
GetBible API를 사용하여 한글 성경 구절을 가져와서 bible_full.json에 채우는 스크립트

사용법:
    python3 scripts/fetch_korean_bible.py
"""

import json
import sys
import time
from pathlib import Path
from urllib.request import urlopen
from urllib.error import URLError

# 누락된 책 ID들과 GetBible API의 책 코드 매핑
BOOK_MAPPINGS = {
    15: "ezra",           # 에스라
    18: "job",            # 욥기
    20: "proverbs",       # 잠언
    28: "hosea",          # 호세아
    33: "micah",          # 미가
    49: "ephesians",      # 에베소서
    50: "philippians",    # 빌립보서
    57: "philemon",       # 빌레몬서
    65: "jude",           # 유다서
    66: "revelation"      # 요한계시록
}

def fetch_book_data(book_name):
    """GetBible API에서 책 데이터 가져오기"""
    url = f"https://getbible.net/json?passage={book_name}&version=korean"

    try:
        print(f"  📡 {book_name} 데이터 가져오는 중...")
        with urlopen(url, timeout=30) as response:
            data = response.read().decode('utf-8')

            # JSONP 형식 제거 (getbible(...))
            if data.startswith('getbible(') and data.endswith(')'):
                data = data[9:-1]

            return json.loads(data)
    except URLError as e:
        print(f"  ❌ 오류: {book_name} - {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON 파싱 오류: {book_name} - {e}")
        return None

def extract_verses_from_getbible(getbible_data, book_name):
    """GetBible API 응답에서 구절 추출"""
    if not getbible_data or 'book' not in getbible_data:
        return None

    chapters_data = []
    book_data = getbible_data['book'][0]

    for chapter_info in book_data.get('chapter', []):
        verses = []
        chapter_num = int(chapter_info['chapter_nr'])

        for verse_num, verse_data in chapter_info.get('verse', {}).items():
            verses.append({
                'verse': int(verse_num),
                'krv': verse_data.get('verse', '').strip(),
                'kjv': ''  # GetBible Korean API에는 영어가 없음
            })

        # 절 번호 순으로 정렬
        verses.sort(key=lambda x: x['verse'])
        chapters_data.append(verses)

    return chapters_data

def main():
    # bible_full.json 파일 경로
    bible_path = Path(__file__).parent.parent / "assets" / "data" / "bible_full.json"

    if not bible_path.exists():
        print(f"❌ 오류: {bible_path} 파일을 찾을 수 없습니다.")
        sys.exit(1)

    # JSON 파일 읽기
    print(f"📖 성경 데이터 로드 중: {bible_path}\n")
    with open(bible_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 책별로 데이터 매핑
    books = {book['id']: book for book in data['books']}

    print("🔍 누락된 한글 구절 채우는 중...\n")

    modified = False
    success_count = 0

    for book_id, book_name in BOOK_MAPPINGS.items():
        if book_id not in books:
            print(f"⚠️  Book ID {book_id}을 찾을 수 없습니다.")
            continue

        book = books[book_id]
        book_name_ko = book.get('name_ko', '알 수 없음')

        print(f"📚 {book_name_ko} ({book_name}) 처리 중...")

        # GetBible API에서 데이터 가져오기
        getbible_data = fetch_book_data(book_name)

        if not getbible_data:
            print(f"  ⚠️  {book_name_ko} 데이터를 가져올 수 없습니다.\n")
            continue

        # 구절 추출
        chapters_data = extract_verses_from_getbible(getbible_data, book_name)

        if not chapters_data:
            print(f"  ⚠️  {book_name_ko} 구절을 추출할 수 없습니다.\n")
            continue

        # 기존 데이터에 한글 구절 채우기
        filled_count = 0
        for chapter_idx, new_chapter_verses in enumerate(chapters_data):
            if chapter_idx >= len(book['chapters']):
                break

            existing_chapter = book['chapters'][chapter_idx]

            for new_verse in new_chapter_verses:
                verse_idx = new_verse['verse'] - 1

                if verse_idx < len(existing_chapter['verses']):
                    existing_verse = existing_chapter['verses'][verse_idx]

                    # 한글 구절이 비어있으면 채우기
                    if not existing_verse.get('krv') or existing_verse['krv'].strip() == '':
                        existing_verse['krv'] = new_verse['krv']
                        filled_count += 1
                        modified = True

        print(f"  ✅ {book_name_ko}: {filled_count}개 구절 채움\n")
        success_count += 1

        # API 호출 간격 (API 제한 방지)
        time.sleep(1)

    if modified:
        # 백업 생성
        backup_path = bible_path.with_suffix('.json.backup')
        print(f"💾 백업 생성 중: {backup_path}")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        # 수정된 데이터 저장
        print(f"💾 수정된 데이터 저장 중: {bible_path}")
        with open(bible_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"\n✅ 완료! {success_count}/{len(BOOK_MAPPINGS)}개 책의 한글 구절을 채웠습니다.")
    else:
        print("\n⚠️  변경 사항이 없습니다.")

if __name__ == "__main__":
    main()
