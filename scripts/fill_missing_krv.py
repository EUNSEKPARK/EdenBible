#!/usr/bin/env python3
"""
누락된 한글 성경(개역한글) 구절을 채우는 스크립트

사용법:
    python3 scripts/fill_missing_krv.py

누락된 책들:
- 에스라 (15)
- 욥기 (18)
- 잠언 (20)
- 호세아 (28)
- 미가 (33)
- 에베소서 (49)
- 빌립보서 (50)
- 빌레몬서 (57)
- 유다서 (65)
- 요한계시록 (66)

참고: 이 스크립트는 예시입니다. 실제 한글 성경 데이터를 가져오려면
적절한 라이선스를 가진 소스에서 가져와야 합니다.
"""

import json
import sys
from pathlib import Path

# 누락된 책 ID들
MISSING_BOOKS = [15, 18, 20, 28, 33, 49, 50, 57, 65, 66]

# 책 ID와 한글 이름 매핑
BOOK_NAMES = {
    15: "에스라",
    18: "욥기",
    20: "잠언",
    28: "호세아",
    33: "미가",
    49: "에베소서",
    50: "빌립보서",
    57: "빌레몬서",
    65: "유다서",
    66: "요한계시록"
}

# 샘플 한글 구절 (첫 구절만 예시로)
SAMPLE_VERSES = {
    20: {  # 잠언
        1: {
            1: "다윗의 아들 이스라엘 왕 솔로몬의 잠언이라",
            2: "이는 지혜와 훈계를 알게 하며 명철의 말씀을 깨닫게 하며",
            3: "지혜롭게, 의롭게, 공평하게, 정직하게 행할 일에 대하여 훈계를 받게 하며"
        }
    },
    65: {  # 유다서
        1: {
            1: "예수 그리스도의 종이요 야고보의 형제인 유다는 부르심을 입은 자 곧 하나님 아버지 안에서 사랑을 얻고 예수 그리스도를 위하여 지키심을 입은 자들에게 편지하노라"
        }
    },
    66: {  # 요한계시록
        1: {
            1: "예수 그리스도의 계시라 이는 하나님이 그에게 주사 반드시 속히 될 일을 그 종들에게 보이시려고 그 천사를 그 종 요한에게 보내어 지시하신 것이라"
        }
    }
}

def main():
    # bible_full.json 파일 경로
    bible_path = Path(__file__).parent.parent / "assets" / "data" / "bible_full.json"

    if not bible_path.exists():
        print(f"오류: {bible_path} 파일을 찾을 수 없습니다.")
        sys.exit(1)

    # JSON 파일 읽기
    print(f"📖 성경 데이터 로드 중: {bible_path}")
    with open(bible_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 책별로 데이터 매핑
    books = {book['id']: book for book in data['books']}

    print("\n🔍 누락된 한글 구절 확인 중...\n")

    modified = False

    for book_id in MISSING_BOOKS:
        if book_id not in books:
            print(f"⚠️  Book ID {book_id} ({BOOK_NAMES.get(book_id, '알 수 없음')})을 찾을 수 없습니다.")
            continue

        book = books[book_id]
        book_name = BOOK_NAMES.get(book_id, book.get('name_ko', '알 수 없음'))

        # 샘플 데이터가 있는 경우에만 채우기
        if book_id in SAMPLE_VERSES:
            print(f"✏️  {book_name} - 샘플 구절 추가 중...")

            for chapter_num, verses in SAMPLE_VERSES[book_id].items():
                if chapter_num <= len(book['chapters']):
                    chapter = book['chapters'][chapter_num - 1]

                    for verse_num, krv_text in verses.items():
                        if verse_num <= len(chapter['verses']):
                            verse = chapter['verses'][verse_num - 1]
                            if not verse.get('krv') or verse['krv'].strip() == '':
                                verse['krv'] = krv_text
                                modified = True
                                print(f"   ✓ {book_name} {chapter_num}:{verse_num}")
        else:
            print(f"⚠️  {book_name} - 한글 데이터가 아직 준비되지 않았습니다.")
            print(f"   이 책의 한글 구절은 수동으로 추가해야 합니다.")

    if modified:
        # 백업 생성
        backup_path = bible_path.with_suffix('.json.backup')
        print(f"\n💾 백업 생성 중: {backup_path}")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        # 수정된 데이터 저장
        print(f"💾 수정된 데이터 저장 중: {bible_path}")
        with open(bible_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print("\n✅ 완료!")
    else:
        print("\n⚠️  변경 사항이 없습니다.")

    print("\n📌 참고:")
    print("   완전한 한글 성경 데이터를 추가하려면:")
    print("   1. 적절한 라이선스를 가진 한글 성경 데이터 소스를 찾으세요")
    print("   2. 대한성서공회 API 또는 공개 성경 데이터베이스 사용을 고려하세요")
    print("   3. 저작권을 준수하여 데이터를 사용하세요")
    print()

if __name__ == "__main__":
    main()
