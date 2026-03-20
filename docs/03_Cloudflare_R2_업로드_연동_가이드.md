# Cloudflare R2 업로드 및 연동 가이드

**문서 버전:** v1.0  
**작성일:** 2026-03-19  
**목적:** 생성된 음원/이미지 에셋을 Cloudflare R2에 업로드하고 Flutter 앱과 연동하는 절차

---

## 1. 왜 Cloudflare R2인가

| 비교 항목 | Cloudflare R2 | Firebase Storage | AWS S3 |
|----------|--------------|-----------------|--------|
| **이그레스(다운로드) 비용** | **무료** | $0.12/GB | $0.09/GB |
| 저장 비용 | $0.015/GB/월 | $0.026/GB/월 | $0.023/GB/월 |
| 무료 티어 | 10GB 저장, 1000만 읽기/월 | 5GB, 1GB/일 전송 | 5GB, 12개월 한정 |
| S3 호환 API | ✅ | ❌ | ✅ (원본) |
| 글로벌 CDN | ✅ (자동) | ✅ | CloudFront 별도 |
| 설정 난이도 | 쉬움 | 쉬움 | 중간 |

> **핵심:** 사용자가 음원 팩을 다운로드할 때마다 수백 MB가 전송됩니다. R2는 이 **이그레스 비용이 무료**이므로 사용자 수가 늘어도 비용이 거의 없습니다.

---

## 2. Cloudflare R2 초기 설정

### 2-1. Cloudflare 계정 생성

1. https://dash.cloudflare.com/sign-up 접속
2. 이메일 + 비밀번호로 가입
3. 무료(Free) 플랜 선택 (R2 사용 가능)

### 2-2. R2 버킷 생성

1. Cloudflare 대시보드 → 좌측 **R2 Object Storage** 클릭
2. **Create bucket** 클릭
3. 설정:
   - Bucket name: `eden-bible-assets`
   - Location hint: `Asia Pacific` (한국 사용자 타겟)
4. **Create bucket** 클릭

### 2-3. 퍼블릭 액세스 설정

R2 버킷을 퍼블릭으로 열어야 앱에서 직접 다운로드할 수 있습니다.

**방법 A: R2.dev 서브도메인 (가장 간단)**

1. 버킷 선택 → **Settings** 탭
2. **Public access** → **R2.dev subdomain** 토글 ON
3. 생성되는 URL: `https://pub-xxxxxxxxxxxx.r2.dev/`

**방법 B: 커스텀 도메인 (권장, 도메인 보유 시)**

1. Cloudflare에 도메인 등록 (예: `eden-bible.app`)
2. 버킷 Settings → **Custom Domains** → **Connect Domain**
3. 서브도메인 입력: `cdn.eden-bible.app`
4. DNS 레코드 자동 생성됨
5. 최종 URL: `https://cdn.eden-bible.app/`

### 2-4. API 토큰 생성 (업로드용)

1. Cloudflare 대시보드 → **R2** → **Manage R2 API Tokens**
2. **Create API token** 클릭
3. 설정:
   - Token name: `eden-bible-upload`
   - Permissions: **Object Read & Write**
   - Specify bucket: `eden-bible-assets`
4. 생성 → **Access Key ID**와 **Secret Access Key** 저장

```bash
# 환경 변수로 저장
export R2_ACCESS_KEY_ID='your_access_key_id'
export R2_SECRET_ACCESS_KEY='your_secret_access_key'
export R2_ENDPOINT='https://<ACCOUNT_ID>.r2.cloudflarestorage.com'
export R2_BUCKET='eden-bible-assets'
export R2_PUBLIC_URL='https://cdn.eden-bible.app'  # 또는 R2.dev URL
```

> Account ID는 Cloudflare 대시보드 우측 사이드바에서 확인 가능.

---

## 3. 디렉토리 구조 (R2 버킷 내부)

```
eden-bible-assets/
├── audio/
│   └── ko/
│       ├── 01_001.opus       # 창세기 1장
│       ├── 01_002.opus
│       ├── ...
│       └── 66_022.opus       # 요한계시록 22장
│
├── images/
│   ├── books/                # 책 대표 이미지 66장
│   │   ├── 01.webp
│   │   └── ...
│   ├── chapters/             # 장 장면 이미지
│   │   ├── 01_001.webp
│   │   └── ...
│   ├── daily/                # 오늘의 말씀 배경 30장
│   │   ├── daily_01.webp
│   │   └── ...
│   ├── share/                # 공유카드 배경 10장
│   │   ├── share_bg_01.webp
│   │   └── ...
│   └── verses/               # 주요 구절 이미지
│       ├── 19_023_001.webp
│       └── ...
│
├── sync/                     # 구절 싱크 데이터
│   ├── 01_001.json
│   └── ...
│
├── packs/                    # 다운로드 팩 (ZIP)
│   ├── audio_pack_01_v1.zip
│   ├── audio_pack_02_v1.zip
│   └── ...
│
└── media_index.json          # 마스터 인덱스
```

---

## 4. 업로드 스크립트

### 4-1. 필수 도구 설치

```bash
# AWS CLI (R2는 S3 호환이므로 AWS CLI 사용 가능)
# macOS
brew install awscli

# 또는 pip
pip install awscli

# 또는 Python boto3 (스크립트용)
pip install boto3
```

### 4-2. AWS CLI R2 프로필 설정

```bash
aws configure --profile r2
# AWS Access Key ID: (R2 Access Key ID 입력)
# AWS Secret Access Key: (R2 Secret Access Key 입력)
# Default region name: auto
# Default output format: json
```

### 4-3. 단일 파일 업로드

```bash
# 음원 1개 업로드
aws s3 cp output/audio/01_001.opus \
  s3://eden-bible-assets/audio/ko/01_001.opus \
  --endpoint-url $R2_ENDPOINT \
  --profile r2 \
  --content-type "audio/opus"

# 이미지 1개 업로드
aws s3 cp processed/books/01.webp \
  s3://eden-bible-assets/images/books/01.webp \
  --endpoint-url $R2_ENDPOINT \
  --profile r2 \
  --content-type "image/webp"
```

### 4-4. 일괄 업로드 스크립트: `upload_to_r2.py`

```python
#!/usr/bin/env python3
"""
에덴 성경책 — Cloudflare R2 일괄 업로드 스크립트

사용법:
  python upload_to_r2.py --type audio --source ./output/audio
  python upload_to_r2.py --type images --source ./processed/images
  python upload_to_r2.py --type packs --source ./output/packs
  python upload_to_r2.py --type all
"""

import os
import sys
import argparse
import boto3
from pathlib import Path
from botocore.config import Config

# ─── R2 설정 ───
R2_ENDPOINT = os.environ.get("R2_ENDPOINT", "")
R2_ACCESS_KEY = os.environ.get("R2_ACCESS_KEY_ID", "")
R2_SECRET_KEY = os.environ.get("R2_SECRET_ACCESS_KEY", "")
R2_BUCKET = os.environ.get("R2_BUCKET", "eden-bible-assets")

# Content-Type 매핑
CONTENT_TYPES = {
    ".opus": "audio/opus",
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".webp": "image/webp",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".json": "application/json",
    ".zip": "application/zip",
}


def get_r2_client():
    """R2 S3 호환 클라이언트 생성"""
    if not R2_ENDPOINT or not R2_ACCESS_KEY:
        print("ERROR: R2 환경 변수를 설정하세요.")
        print("  export R2_ENDPOINT='https://<ACCOUNT_ID>.r2.cloudflarestorage.com'")
        print("  export R2_ACCESS_KEY_ID='...'")
        print("  export R2_SECRET_ACCESS_KEY='...'")
        sys.exit(1)

    return boto3.client(
        "s3",
        endpoint_url=R2_ENDPOINT,
        aws_access_key_id=R2_ACCESS_KEY,
        aws_secret_access_key=R2_SECRET_KEY,
        config=Config(
            region_name="auto",
            retries={"max_attempts": 3, "mode": "adaptive"}
        ),
    )


def upload_file(client, local_path: str, r2_key: str, content_type: str = None):
    """단일 파일 업로드"""
    if not content_type:
        ext = Path(local_path).suffix.lower()
        content_type = CONTENT_TYPES.get(ext, "application/octet-stream")

    try:
        file_size = os.path.getsize(local_path) / 1024 / 1024  # MB

        # 100MB 이상은 멀티파트 업로드
        extra_args = {"ContentType": content_type}
        if content_type.startswith("audio/") or content_type.startswith("image/"):
            extra_args["CacheControl"] = "public, max-age=31536000"  # 1년 캐시

        client.upload_file(
            Filename=local_path,
            Bucket=R2_BUCKET,
            Key=r2_key,
            ExtraArgs=extra_args,
        )
        return True
    except Exception as e:
        print(f"  ❌ 업로드 실패: {r2_key} — {e}")
        return False


def upload_directory(client, source_dir: str, r2_prefix: str):
    """디렉토리 내 모든 파일을 R2에 업로드"""
    source = Path(source_dir)
    if not source.exists():
        print(f"ERROR: 디렉토리가 존재하지 않습니다: {source_dir}")
        return

    files = [f for f in source.rglob("*") if f.is_file()]
    total = len(files)
    success = 0
    failed = 0

    print(f"\n📤 업로드 시작: {source_dir} → s3://{R2_BUCKET}/{r2_prefix}")
    print(f"   파일 수: {total}")

    for i, file_path in enumerate(sorted(files)):
        relative = file_path.relative_to(source)
        r2_key = f"{r2_prefix}/{relative}"
        file_size = file_path.stat().st_size / 1024 / 1024

        print(f"  [{i+1}/{total}] {r2_key} ({file_size:.1f}MB) ", end="")

        if upload_file(client, str(file_path), r2_key):
            success += 1
            print("✅")
        else:
            failed += 1

    print(f"\n  결과: ✅ {success} 성공, ❌ {failed} 실패")
    return success, failed


def upload_audio(client, source_dir: str):
    """음원 파일 업로드"""
    upload_directory(client, source_dir, "audio/ko")


def upload_images(client, source_dir: str):
    """이미지 파일 업로드 (하위 폴더 구조 유지)"""
    source = Path(source_dir)
    for subdir in ["books", "chapters", "daily", "share", "verses"]:
        subpath = source / subdir
        if subpath.exists():
            upload_directory(client, str(subpath), f"images/{subdir}")


def upload_packs(client, source_dir: str):
    """다운로드 팩 ZIP 업로드"""
    upload_directory(client, source_dir, "packs")


def upload_sync(client, source_dir: str):
    """싱크 데이터 업로드"""
    upload_directory(client, source_dir, "sync")


def upload_index(client, index_path: str):
    """media_index.json 업로드"""
    print(f"\n📤 인덱스 업로드: {index_path}")
    if upload_file(client, index_path, "media_index.json", "application/json"):
        print("  ✅ media_index.json 업로드 완료")


def list_bucket(client):
    """버킷 내용물 확인"""
    print(f"\n📋 버킷 내용: s3://{R2_BUCKET}")
    response = client.list_objects_v2(Bucket=R2_BUCKET, MaxKeys=50)
    
    if "Contents" not in response:
        print("  (비어있음)")
        return

    total_size = 0
    for obj in response["Contents"]:
        size = obj["Size"] / 1024 / 1024
        total_size += size
        print(f"  {obj['Key']:60} {size:>8.2f} MB")

    if response.get("IsTruncated"):
        print(f"  ... (더 많은 파일이 있습니다)")
    print(f"\n  총 크기: {total_size:.1f} MB")


def main():
    parser = argparse.ArgumentParser(description="에덴 성경책 R2 업로드")
    parser.add_argument("--type", choices=["audio", "images", "packs", "sync", "index", "all", "list"],
                        required=True, help="업로드 대상")
    parser.add_argument("--source", default="./output", help="소스 디렉토리")
    parser.add_argument("--index-file", default="./media_index.json", help="media_index.json 경로")
    args = parser.parse_args()

    client = get_r2_client()

    if args.type == "list":
        list_bucket(client)
    elif args.type == "audio":
        upload_audio(client, os.path.join(args.source, "audio"))
    elif args.type == "images":
        upload_images(client, os.path.join(args.source, "images"))
    elif args.type == "packs":
        upload_packs(client, os.path.join(args.source, "packs"))
    elif args.type == "sync":
        upload_sync(client, os.path.join(args.source, "sync"))
    elif args.type == "index":
        upload_index(client, args.index_file)
    elif args.type == "all":
        upload_audio(client, os.path.join(args.source, "audio"))
        upload_images(client, os.path.join(args.source, "images"))
        upload_sync(client, os.path.join(args.source, "sync"))
        upload_packs(client, os.path.join(args.source, "packs"))
        upload_index(client, args.index_file)
        print("\n🎉 전체 업로드 완료!")

    # 최종 URL 안내
    public_url = os.environ.get("R2_PUBLIC_URL", "https://your-r2-url.r2.dev")
    print(f"\n🌐 퍼블릭 URL 예시:")
    print(f"   음원: {public_url}/audio/ko/01_001.opus")
    print(f"   이미지: {public_url}/images/books/01.webp")
    print(f"   팩: {public_url}/packs/audio_pack_01_v1.zip")
    print(f"   인덱스: {public_url}/media_index.json")


if __name__ == "__main__":
    main()
```

### 4-5. 다운로드 팩 생성 스크립트: `create_packs.py`

```python
#!/usr/bin/env python3
"""
음원 + 이미지를 9개 팩으로 묶어 ZIP 파일 생성

사용법:
  python create_packs.py \
    --audio-dir ./output/audio \
    --images-dir ./processed/images/chapters \
    --sync-dir ./output/sync \
    --output-dir ./output/packs
"""

import os
import json
import zipfile
import argparse
from pathlib import Path

# 팩 정의 (book_id 범위)
PACKS = [
    {"id": "pack_01", "name": "모세오경",       "books": list(range(1, 6))},
    {"id": "pack_02", "name": "역사서 (상)",    "books": list(range(6, 11))},
    {"id": "pack_03", "name": "역사서 (하)",    "books": list(range(11, 18))},
    {"id": "pack_04", "name": "시가서",         "books": list(range(18, 23))},
    {"id": "pack_05", "name": "대선지서",       "books": list(range(23, 28))},
    {"id": "pack_06", "name": "소선지서",       "books": list(range(28, 40))},
    {"id": "pack_07", "name": "복음서",         "books": list(range(40, 44))},
    {"id": "pack_08", "name": "사도행전~서신",  "books": list(range(44, 58))},
    {"id": "pack_09", "name": "일반서신~계시록","books": list(range(58, 67))},
]

def create_pack(pack: dict, audio_dir: str, images_dir: str, 
                sync_dir: str, output_dir: str):
    """하나의 팩 ZIP 생성"""
    pack_id = pack["id"]
    zip_path = os.path.join(output_dir, f"audio_{pack_id}_v1.zip")
    
    print(f"\n📦 {pack['name']} ({pack_id}) 생성 중...")

    file_count = 0
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for book_id in pack["books"]:
            # 음원 파일
            for f in sorted(Path(audio_dir).glob(f"{book_id:02d}_*.opus")):
                arcname = f"audio/{f.name}"
                zf.write(str(f), arcname)
                file_count += 1

            for f in sorted(Path(audio_dir).glob(f"{book_id:02d}_*.wav")):
                arcname = f"audio/{f.name}"
                zf.write(str(f), arcname)
                file_count += 1

            # 장 이미지
            if os.path.exists(images_dir):
                for f in sorted(Path(images_dir).glob(f"{book_id:02d}_*.webp")):
                    arcname = f"images/chapters/{f.name}"
                    zf.write(str(f), arcname)
                    file_count += 1

            # 싱크 데이터
            if os.path.exists(sync_dir):
                for f in sorted(Path(sync_dir).glob(f"{book_id:02d}_*.json")):
                    arcname = f"sync/{f.name}"
                    zf.write(str(f), arcname)
                    file_count += 1

    if file_count == 0:
        os.remove(zip_path)
        print(f"  ⚠ 파일 없음, ZIP 생성 취소")
        return

    size_mb = os.path.getsize(zip_path) / 1024 / 1024
    print(f"  ✅ {file_count}개 파일 → {zip_path} ({size_mb:.1f}MB)")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--audio-dir", default="./output/audio")
    parser.add_argument("--images-dir", default="./processed/images/chapters")
    parser.add_argument("--sync-dir", default="./output/sync")
    parser.add_argument("--output-dir", default="./output/packs")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    for pack in PACKS:
        create_pack(pack, args.audio_dir, args.images_dir, 
                    args.sync_dir, args.output_dir)

    print("\n🎉 모든 팩 생성 완료!")


if __name__ == "__main__":
    main()
```

---

## 5. Flutter 앱 연동

### 5-1. media_index.json에 R2 URL 설정

```json
{
  "version": "1.0.0",
  "audio": {
    "base_url": "https://cdn.eden-bible.app/audio/ko/",
    "packs": {
      "pack_01": {
        "download_url": "https://cdn.eden-bible.app/packs/audio_pack_01_v1.zip"
      }
    }
  },
  "images": {
    "base_url": "https://cdn.eden-bible.app/images/"
  }
}
```

### 5-2. Flutter에서 R2 파일 다운로드

```dart
import 'package:http/http.dart' as http;
import 'dart:io';

const baseUrl = 'https://cdn.eden-bible.app';

/// 단일 음원 스트리밍/다운로드
Future<File> downloadAudio(int bookId, int chapter) async {
  final filename = '${bookId.toString().padLeft(2, '0')}_'
                   '${chapter.toString().padLeft(3, '0')}.opus';
  final url = '$baseUrl/audio/ko/$filename';
  
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/cache/audio/$filename');
    await file.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
  throw Exception('Download failed: ${response.statusCode}');
}

/// 팩 다운로드 (백그라운드, 진행률 콜백)
Future<void> downloadPack(String packId, Function(double) onProgress) async {
  final url = '$baseUrl/packs/audio_${packId}_v1.zip';
  final request = http.Request('GET', Uri.parse(url));
  final response = await http.Client().send(request);
  
  final totalBytes = response.contentLength ?? 0;
  var receivedBytes = 0;
  final chunks = <int>[];
  
  await for (var chunk in response.stream) {
    chunks.addAll(chunk);
    receivedBytes += chunk.length;
    if (totalBytes > 0) {
      onProgress(receivedBytes / totalBytes);
    }
  }
  
  // ZIP 해제 → 로컬 저장
  // ...
}
```

### 5-3. CORS 설정 (필요 시)

R2 퍼블릭 액세스를 사용하면 보통 CORS 문제가 없지만, 웹앱에서 접근 시 필요할 수 있습니다.

Cloudflare 대시보드 → R2 버킷 → Settings → **CORS Policy**:

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 86400
  }
]
```

---

## 6. 운영 체크리스트

### 6-1. 업로드 전 확인

- [ ] R2 환경 변수 설정 완료
- [ ] 파일 네이밍 컨벤션 준수 (`01_001.opus`, `01.webp` 등)
- [ ] Content-Type 올바르게 설정
- [ ] 파일럿 음원/이미지 품질 검수 완료

### 6-2. 업로드 후 확인

- [ ] 퍼블릭 URL로 파일 접근 가능 확인
- [ ] 브라우저에서 음원 재생 테스트
- [ ] 이미지 로딩 테스트
- [ ] media_index.json URL 접근 가능 확인
- [ ] Flutter 앱에서 다운로드 테스트

### 6-3. 비용 모니터링

- Cloudflare 대시보드 → R2 → Usage 탭에서 확인
- 월별 저장 용량, 요청 수 모니터링
- 이그레스는 무료이므로 저장 비용만 관리

---

## 7. 전체 워크플로우 요약

```
1. 음원 생성
   bible_full.json → generate_bible_audio.py → output/audio/*.wav
                                                    ↓
2. 포맷 변환                                   ffmpeg → *.opus

3. 이미지 생성
   Midjourney → raw/*.png → cwebp → processed/images/**/*.webp

4. 팩 생성
   create_packs.py → output/packs/audio_pack_*.zip

5. R2 업로드
   upload_to_r2.py --type all → s3://eden-bible-assets/

6. 인덱스 업데이트
   media_index.json 수정 → upload_to_r2.py --type index

7. 앱 연동
   Flutter MediaAssetService → R2 URL로 다운로드/스트리밍
```

---

**문서 끝 | 프로젝트 에덴 · Cloudflare R2 업로드 및 연동 가이드 v1.0**