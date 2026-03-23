#!/usr/bin/env python3
"""
thiagobodruk/bible 레포지토리의 ko_ko.json에서 누락된 한글 구절을 채우는 스크립트

사용법:
    python3 scripts/fill_from_thiagobodruk.py
"""

import json
import sys
from pathlib import Path

# 누락된 책 ID와 약어 매핑
BOOK_MAPPINGS = {
    15: 'ezr',   # 에스라
    18: 'job',   # 욥기
    28: 'ho',    # 호세아
    33: 'mi',    # 미가
    49: 'eph',   # 에베소서
    50: 'ph',    # 빌립보서
    57: 'phm'    # 빌레몬서
}

def main():
    # 파일 경로
    bible_path = Path(__file__).parent.parent / "assets" / "data" / "bible_full.json"
    source_path = Path("/tmp/ko_ko.json")

    if not bible_path.exists():
        print(f"❌ 오류: {bible_path} 파일을 찾을 수 없습니다.")
        sys.exit(1)

    if not source_path.exists():
        print(f"❌ 오류: {source_path} 파일을 찾을 수 없습니다.")
        print("   먼저 다음 명령어를 실행하세요:")
        print("   curl -sL 'https://raw.githubusercontent.com/thiagobodruk/bible/master/json/ko_ko.json' -o /tmp/ko_ko.json")
        sys.exit(1)

    # 소스 데이터 로드 (thiagobodruk)
    print(f"📖 소스 데이터 로드 중: {source_path}")
    with open(source_path, 'r', encoding='utf-8-sig') as f:
        source_data = json.load(f)

    # 약어로 인덱싱
    source_books = {book['abbrev']: book for book in source_data}

    # 대상 데이터 로드 (bible_full.json)
    print(f"📖 대상 데이터 로드 중: {bible_path}\n")
    with open(bible_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    # 책별로 데이터 매핑
    target_books = {book['id']: book for book in target_data['books']}

    print("🔍 누락된 한글 구절 채우는 중...\n")

    modified = False
    total_filled = 0

    for book_id, abbrev in BOOK_MAPPINGS.items():
        if book_id not in target_books:
            print(f"⚠️  Book ID {book_id}을 찾을 수 없습니다.")
            continue

        if abbrev not in source_books:
            print(f"⚠️  약어 '{abbrev}'을 소스에서 찾을 수 없습니다.")
            continue

        target_book = target_books[book_id]
        source_book = source_books[abbrev]

        book_name = target_book.get('name_ko', '알 수 없음')
        print(f"📚 {book_name} ({abbrev}) 처리 중...")

        filled_count = 0

        # 장별로 처리
        for chapter_idx, source_chapter in enumerate(source_book['chapters']):
            if chapter_idx >= len(target_book['chapters']):
                print(f"  ⚠️  {chapter_idx + 1}장이 대상에 존재하지 않습니다.")
                continue

            target_chapter = target_book['chapters'][chapter_idx]

            # 구절별로 처리
            for verse_idx, korean_text in enumerate(source_chapter):
                if verse_idx >= len(target_chapter['verses']):
                    # 대상에 절이 없으면 추가
                    target_chapter['verses'].append({
                        'verse': verse_idx + 1,
                        'krv': korean_text.strip(),
                        'kjv': ''
                    })
                    filled_count += 1
                    modified = True
                else:
                    target_verse = target_chapter['verses'][verse_idx]

                    # 한글 구절이 비어있거나 절 번호가 맞지 않으면 채우기
                    if not target_verse.get('krv') or target_verse['krv'].strip() == '':
                        target_verse['krv'] = korean_text.strip()
                        filled_count += 1
                        modified = True

        print(f"  ✅ {book_name}: {filled_count}개 구절 채움\n")
        total_filled += filled_count

    if modified:
        # 백업 생성
        backup_path = bible_path.with_suffix('.json.backup3')
        print(f"💾 백업 생성 중: {backup_path}")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(target_data, f, ensure_ascii=False, indent=2)

        # 수정된 데이터 저장
        print(f"💾 수정된 데이터 저장 중: {bible_path}")
        with open(bible_path, 'w', encoding='utf-8') as f:
            json.dump(target_data, f, ensure_ascii=False, indent=2)

        print(f"\n✅ 완료! 총 {total_filled}개의 한글 구절을 채웠습니다.")
        print(f"   {len(BOOK_MAPPINGS)}개 책이 업데이트되었습니다.")
    else:
        print("\n⚠️  변경 사항이 없습니다.")

if __name__ == "__main__":
    main()
