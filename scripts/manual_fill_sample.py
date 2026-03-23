#!/usr/bin/env python3
"""
주요 책의 샘플 한글 구절을 수동으로 채우는 스크립트
- 잠언 1장
- 유다서 1장
- 요한계시록 1장
"""

import json
import sys
from pathlib import Path

# 샘플 한글 구절 데이터 (개역한글)
SAMPLE_DATA = {
    20: {  # 잠언
        1: {  # 1장
            1: "다윗의 아들 이스라엘 왕 솔로몬의 잠언이라",
            2: "이는 지혜와 훈계를 알게 하며 명철의 말씀을 깨닫게 하며",
            3: "지혜롭게, 의롭게, 공평하게, 정직하게 행할 일에 대하여 훈계를 받게 하며",
            4: "어리석은 자로 슬기롭게 하며 젊은 자에게 지식과 근신함을 주기 위한 것이니",
            5: "지혜 있는 자는 듣고 학식이 더할 것이요 명철한 자는 모략을 얻을 것이라",
            6: "잠언과 비유와 지혜 있는 자의 말과 그 오묘한 말을 깨달으리라",
            7: "여호와를 경외하는 것이 지식의 근본이어늘 미련한 자는 지혜와 훈계를 멸시하느니라",
        }
    },
    65: {  # 유다서
        1: {  # 1장
            1: "예수 그리스도의 종이요 야고보의 형제인 유다는 부르심을 입은 자 곧 하나님 아버지 안에서 사랑을 얻고 예수 그리스도를 위하여 지키심을 입은 자들에게 편지하노라",
            2: "긍휼과 평강과 사랑이 너희에게 더욱 많을찌어다",
            3: "사랑하는 자들아 우리의 일반으로 얻은 구원을 들어 너희에게 편지하려는 뜻이 간절하던 차에 성도에게 단번에 주신 믿음의 도를 위하여 힘써 싸우라는 편지로 너희를 권하여야 할 필요를 느꼈노니",
            4: "이는 가만히 들어온 사람 몇이 있음이라 저희는 옛적부터 이 판결을 받기로 미리 기록된 자니 경건치 아니하여 우리 하나님의 은혜를 도리어 색욕거리로 바꾸고 홀로 하나이신 주재 곧 우리 주 예수 그리스도를 부인하는 자니라",
            5: "너희가 본래 범사를 알았으나 내가 너희로 다시 생각나게 하고자 하노라 주께서 백성을 애굽에서 구원하여 내시고 후에 믿지 아니하는 자들을 멸하셨으며",
        }
    },
    66: {  # 요한계시록
        1: {  # 1장
            1: "예수 그리스도의 계시라 이는 하나님이 그에게 주사 반드시 속히 될 일을 그 종들에게 보이시려고 그 천사를 그 종 요한에게 보내어 지시하신 것이라",
            2: "요한은 하나님의 말씀과 예수 그리스도의 증거 곧 자기의 본 것을 다 증거하였느니라",
            3: "이 예언의 말씀을 읽는 자와 듣는 자들과 그 가운데 기록한 것을 지키는 자들이 복이 있나니 때가 가까움이라",
            4: "요한은 아시아에 있는 일곱 교회에 편지하노니 이제도 계시고 전에도 계시고 장차 오실 이와 그 보좌 앞에 일곱 영과",
            5: "또 충성된 증인으로 죽은 자들 가운데서 먼저 나시고 땅의 임금들의 머리가 되신 예수 그리스도로 말미암아 은혜와 평강이 너희에게 있기를 원하노라 우리를 사랑하사 그의 피로 우리 죄에서 우리를 해방하시고",
            6: "그 아버지 하나님을 위하여 우리를 나라와 제사장으로 삼으신 그에게 영광과 능력이 세세토록 있기를 원하노라 아멘",
            7: "볼찌어다 구름을 타고 오시리라 각인의 눈이 그를 보겠고 그를 찌른 자들도 볼 터이요 땅에 있는 모든 족속이 그를 인하여 애곡하리니 그러하리라 아멘",
            8: "주 하나님이 가라사대 나는 알파와 오메가라 이제도 있고 전에도 있었고 장차 올 자요 전능한 자라 하시더라",
        }
    }
}

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

    print("🔍 샘플 한글 구절 채우는 중...\n")

    modified = False
    book_names = {20: "잠언", 65: "유다서", 66: "요한계시록"}

    for book_id, chapters_data in SAMPLE_DATA.items():
        if book_id not in books:
            print(f"⚠️  Book ID {book_id}을 찾을 수 없습니다.")
            continue

        book = books[book_id]
        book_name = book_names.get(book_id, book.get('name_ko', '알 수 없음'))

        print(f"📚 {book_name} 처리 중...")

        filled_count = 0
        for chapter_num, verses_data in chapters_data.items():
            chapter_idx = chapter_num - 1

            if chapter_idx >= len(book['chapters']):
                print(f"  ⚠️  {chapter_num}장이 존재하지 않습니다.")
                continue

            chapter = book['chapters'][chapter_idx]

            for verse_num, krv_text in verses_data.items():
                verse_idx = verse_num - 1

                if verse_idx < len(chapter['verses']):
                    verse = chapter['verses'][verse_idx]

                    # 한글 구절이 비어있으면 채우기
                    if not verse.get('krv') or verse['krv'].strip() == '':
                        verse['krv'] = krv_text
                        filled_count += 1
                        modified = True

        print(f"  ✅ {book_name}: {filled_count}개 구절 채움\n")

    if modified:
        # 백업 생성
        backup_path = bible_path.with_suffix('.json.backup2')
        print(f"💾 백업 생성 중: {backup_path}")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        # 수정된 데이터 저장
        print(f"💾 수정된 데이터 저장 중: {bible_path}")
        with open(bible_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"\n✅ 완료! 샘플 한글 구절을 채웠습니다.")
        print("\n📌 참고: 이것은 샘플 데이터입니다. 전체 구절을 채우려면")
        print("   적절한 라이선스를 가진 한글 성경 데이터를 사용하세요.")
    else:
        print("\n⚠️  변경 사항이 없습니다.")

if __name__ == "__main__":
    main()
