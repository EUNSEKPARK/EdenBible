# 프로젝트 에덴 — 차별화 UX · 버튼형 AI · 유튜브 연동 개발 설계서

**문서 버전:** v1.0  
**작성일:** 2026-03-19  
**목적:** 기존 대형 성경 앱(YouVersion, 바이블 애플, 갓피플) 대비 차별화 전략을 코드 레벨까지 설계  
**핵심 슬로건:** _"성경 앱이 아니라, 성경을 도구로 쓰는 멘탈 헬스케어 앱"_

---

## 1. 시장 분석 — 왜 또 다른 성경 앱인가

### 1-1. 기존 대형 성경 앱의 한계

| 앱 | 장점 | 약점 |
|----|------|------|
| **YouVersion** (5억+ DL) | 완전 무료, 2400+ 번역, 커뮤니티 | UI가 정보 과잉, 탐색이 드롭다운 의존 |
| **바이블 애플** (500만+ DL) | 다번역, 13종 역본, 공동체 읽기 | 투박한 UI, 2010년대 디자인 |
| **갓피플 성경** (500만+ DL) | 통독 모임, 50개 기능 | 기능 과다로 복잡, 시각적 매력 부족 |
| **매일성경** (100만+ DL) | 큐티 해설 우수 | 유료 구독 필수, 성경 본문이 구독 뒤 |

### 1-2. 에덴이 파고드는 틈새

```
기존 앱들 = "무겁고 딱딱한 백과사전"
          → 드롭다운, 단순 텍스트, 기능 과잉

에덴      = "내 마음을 알아주는 세련된 큐레이션 매거진"
          → 비주얼 썸네일, 감정 매칭 AI, 유튜브 연동
```

**에덴의 3대 차별 축:**

1. 🎨 **비주얼 네비게이션** — 성경 66권을 썸네일 카드+줌으로 탐색 (기존: 드롭다운)
2. 🤖 **버튼형 감정 매칭 AI** — 채팅/음성 없이 탭만으로 위로 (기존: 없음)
3. 📺 **유튜브 큐레이션 허브** — 검증된 찬양/설교 자동 추천 (기존: 없음)

---

## 2. UI/UX 혁신 — "성경의 인스타그램"

### 2-1. 비주얼 썸네일 네비게이션

기존 앱의 성경 탐색: `드롭다운 → 권 선택 → 장 선택 → 절 스크롤`  
에덴의 성경 탐색: `썸네일 그리드 → 탭 → 장 카드 → 스와이프`

#### 성경 66권 썸네일 그리드

```
┌─────────────────────────────────────────────────────────┐
│  🔍 검색                              [구약] [신약]      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                  │
│   │ 🌍   │ │ 🏔   │ │ ⛺   │ │ 📜   │                  │
│   │창세기 │ │출애굽│ │레위기│ │ 민수 │                  │
│   │ 50장  │ │ 40장 │ │ 27장 │ │ 36장 │                  │
│   └──────┘ └──────┘ └──────┘ └──────┘                  │
│                                                          │
│   ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                  │
│   │ 📖   │ │ ⚔   │ │ 💕   │ │ 👑   │                  │
│   │신명기 │ │여호수│ │ 룻기 │ │사무엘│                  │
│   │ 34장  │ │ 24장 │ │  4장 │ │ 31장 │                  │
│   └──────┘ └──────┘ └──────┘ └──────┘                  │
│                                                          │
│   ← 스크롤하여 66권 전체 탐색 →                          │
└─────────────────────────────────────────────────────────┘
```

**디자인 원칙:**
- 구약 = 따뜻한 갈색·녹색 톤 (대지, 자연)
- 신약 = 밝은 하늘색·금색 톤 (은혜, 빛)
- 각 권 고유 Midjourney 일러스트 (이미 `02_Midjourney_이미지_생성_가이드.md`에 66장 프롬프트 완성)

#### Flutter 구현 — 비주얼 책 선택기

```dart
/// 성경 66권 비주얼 그리드 — 드롭다운 대체
class VisualBookGrid extends StatelessWidget {
  final List<BibleBook> books;
  final void Function(int bookId) onSelect;

  const VisualBookGrid({super.key, required this.books, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookThumbnailCard(
          book: book,
          onTap: () => onSelect(book.id),
        );
      },
    );
  }
}

class _BookThumbnailCard extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onTap;
  const _BookThumbnailCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOT = book.id <= 39; // 구약 39권

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 썸네일 이미지 (Midjourney 생성)
            Image.asset(
              'assets/images/books/${book.id.toString().padLeft(2, '0')}.webp',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: isOT ? const Color(0xFF8B7355) : const Color(0xFF6B8FB5),
              ),
            ),
            // 하단 그라디언트
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // 텍스트
            Positioned(
              left: 8, right: 8, bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.nameKo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${book.chapterCount}장',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2-2. 장 선택 — 카드 스택 방식

기존: 숫자만 나열된 그리드  
에덴: 각 장의 핵심 구절이 미리보기로 표시되는 카드

```
┌─────────────────────────────────┐
│  ← 창세기                        │
│                                  │
│  ┌───────────────────────────┐  │
│  │ 1장                        │  │
│  │ "태초에 하나님이 천지를     │  │
│  │  창조하시니라"              │  │
│  │                  31절 ──── │  │
│  └───────────────────────────┘  │
│                                  │
│  ┌───────────────────────────┐  │
│  │ 2장                        │  │
│  │ "하나님이 그 일곱째 날에   │  │
│  │  안식하시니라"              │  │
│  │                  25절 ──── │  │
│  └───────────────────────────┘  │
│                                  │
│  ┌───────────────────────────┐  │
│  │ 3장                        │  │
│  │ "뱀이 여자에게 물으니라"   │  │
│  │                  24절 ──── │  │
│  └───────────────────────────┘  │
│                                  │
│  ↕ 스크롤                        │
└─────────────────────────────────┘
```

### 2-3. 다이내믹 줌 (Zoom) 네비게이션

전체 지도 → 줌인 → 장 → 절 순으로 들어가는 인터페이스:

```
레벨 1: 66권 전체 지도 (한 화면에 모든 권이 보임)
  ↓ 핀치 줌인 또는 탭
레벨 2: 선택한 권의 장 카드 (창세기 50장이 카드로)
  ↓ 탭
레벨 3: 선택한 장의 본문 (기존 읽기 뷰)
```

```dart
/// 줌 네비게이션 구현 — InteractiveViewer 활용
class ZoomBibleNavigation extends StatefulWidget {
  const ZoomBibleNavigation({super.key});
  @override
  State<ZoomBibleNavigation> createState() => _ZoomBibleNavigationState();
}

class _ZoomBibleNavigationState extends State<ZoomBibleNavigation> {
  final TransformationController _controller = TransformationController();
  int? _selectedBookId;

  @override
  Widget build(BuildContext context) {
    if (_selectedBookId != null) {
      // 레벨 2: 장 카드 뷰
      return _ChapterCardView(
        bookId: _selectedBookId!,
        onBack: () => setState(() => _selectedBookId = null),
      );
    }

    // 레벨 1: 66권 전체 줌 지도
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 0.5,
      maxScale: 3.0,
      child: VisualBookGrid(
        books: BibleDataService().books,
        onSelect: (bookId) => setState(() => _selectedBookId = bookId),
      ),
    );
  }
}
```

---

## 3. 버튼형 감정 매칭 AI — 채팅 없는 위로

### 3-1. 설계 철학

```
기존 AI 상담 = 채팅 입력 → 타이핑이 귀찮고 → 음성은 부정확
에덴 AI    = 버튼 탭 → 즉시 매칭 → 말씀+위로+유튜브 한 화면
```

**핵심:** 사용자는 자신의 감정을 "설명"하기보다 "선택"하고 싶어 합니다.

### 3-2. 3단계 버튼 흐름

```
[1단계: 감정 대분류]        [2단계: 세부 상황]           [3단계: 힐링 패키지]
                                                        
┌──────────┐               ┌──────────────────┐         ┌─────────────────────┐
│ 😔 불안   │ ──탭──→      │ 미래에 대한 걱정  │ ─탭─→  │ AI 한마디:           │
│ 😢 슬픔   │               │ 경제적 어려움     │         │ "많이 지치셨죠?"     │
│ 💔 관계   │               │ 건강 문제         │         │                     │
│ 🙏 감사   │               │ 시험/진로         │         │ 📖 말씀 카드:        │
│ 😤 분노   │               │ 가족 걱정         │         │ "너희 중에 지혜가    │
│ 😴 지침   │               └──────────────────┘         │  부족한 자가..."     │
│ 🌙 잠이안옴│                                            │ - 야고보서 1:5       │
│ 😊 기쁨   │                                            │                     │
│ ❓ 방향상실│                                            │ 🎵 유튜브 추천:      │
│ 💪 용기필요│                                            │ "불안할 때 듣는 찬양" │
└──────────┘                                            │                     │
                                                        │ 🙏 기도 가이드       │
                                                        └─────────────────────┘
```

### 3-3. 감정 데이터 구조 (emotion_map.json)

```json
{
  "categories": [
    {
      "id": "anxiety",
      "emoji": "😔",
      "label": "불안",
      "color": "#7B8FA1",
      "situations": [
        {
          "id": "anxiety_future",
          "label": "미래에 대한 걱정",
          "icon": "hourglass_empty",
          "response": {
            "ai_message": "미래가 막막하게 느껴지시나요? 하나님은 당신의 내일을 이미 알고 계세요. 오늘 이 말씀이 당신의 마음에 평안을 가져다 주길 기도합니다.",
            "verses": [
              {
                "ref": "예레미야 29:11",
                "text": "나 여호와가 너희를 향한 나의 생각을 아나니 재앙이 아니라 곧 평안이요 너희 장래에 소망을 주려 하는 생각이라",
                "book_id": 24, "chapter": 29, "verse": 11
              },
              {
                "ref": "마태복음 6:34",
                "text": "그러므로 내일 일을 위하여 염려하지 말라 내일 일은 내일 염려할 것이요 한 날 괴로움은 그 날에 족하니라",
                "book_id": 40, "chapter": 6, "verse": 34
              }
            ],
            "prayer_guide": "사랑하는 하나님, 보이지 않는 내일이 두렵습니다. 그러나 주님이 나의 내일을 붙잡고 계심을 믿습니다. 오늘 하루도 주님께 맡깁니다. 아멘.",
            "youtube_keywords": ["불안할 때 찬양", "미래 걱정 설교", "평안 묵상 음악"],
            "youtube_curated": [
              {"title": "불안한 마음에 평안을 주는 찬양 모음", "channel": "worship_channel_id", "video_id": "abc123"},
              {"title": "걱정이 많을 때 듣는 설교", "channel": "sermon_channel_id", "video_id": "def456"}
            ]
          }
        },
        {
          "id": "anxiety_money",
          "label": "경제적 어려움",
          "icon": "account_balance_wallet",
          "response": {
            "ai_message": "물질적인 걱정이 마음을 무겁게 하고 있군요. 하나님은 공중의 새도 먹이시는 분입니다. 당신의 필요를 아시는 하나님을 신뢰해 보세요.",
            "verses": [
              {
                "ref": "빌립보서 4:19",
                "text": "나의 하나님이 그리스도 예수 안에서 영광 가운데 그 풍성한대로 너희 모든 쓸 것을 채우시리라",
                "book_id": 50, "chapter": 4, "verse": 19
              }
            ],
            "prayer_guide": "하나님 아버지, 경제적으로 어려운 시간을 보내고 있습니다. 주님이 공급하시는 분이심을 믿고 의지합니다. 아멘.",
            "youtube_keywords": ["경제적 어려움 설교", "물질 걱정 찬양"],
            "youtube_curated": []
          }
        },
        {
          "id": "anxiety_health",
          "label": "건강 문제",
          "icon": "health_and_safety",
          "response": {
            "ai_message": "건강에 대한 걱정이 크시군요. 몸이 아프면 마음도 함께 힘들어지죠. 치료하시는 하나님이 당신과 함께 하십니다.",
            "verses": [
              {
                "ref": "시편 103:3",
                "text": "네 모든 죄악을 사하시며 네 모든 병을 고치시고",
                "book_id": 19, "chapter": 103, "verse": 3
              },
              {
                "ref": "이사야 53:5",
                "text": "그가 찔림은 우리의 허물을 인함이요 그가 상함은 우리의 죄악을 인함이라 그가 징계를 받음으로 우리가 평화를 누리고 그가 채찍에 맞음으로 우리가 나음을 입었도다",
                "book_id": 23, "chapter": 53, "verse": 5
              }
            ],
            "prayer_guide": "주님, 몸이 아파서 두렵습니다. 치료자이신 하나님께 온전히 맡깁니다. 빠르게 회복하게 해 주세요. 아멘.",
            "youtube_keywords": ["아플 때 찬양", "치유 기도"],
            "youtube_curated": []
          }
        }
      ]
    },
    {
      "id": "sadness",
      "emoji": "😢",
      "label": "슬픔",
      "color": "#6B7B8D",
      "situations": [
        {
          "id": "sadness_loss",
          "label": "소중한 사람을 잃은 슬픔",
          "icon": "favorite_border",
          "response": {
            "ai_message": "큰 슬픔 가운데 계시는군요. 눈물을 흘려도 괜찮습니다. 하나님도 함께 우시는 분입니다.",
            "verses": [
              {"ref": "시편 34:18", "text": "여호와는 마음이 상한 자에게 가까이 하시고 중심에 통회하는 자를 구원하시는도다", "book_id": 19, "chapter": 34, "verse": 18},
              {"ref": "요한복음 11:35", "text": "예수께서 눈물을 흘리시더라", "book_id": 43, "chapter": 11, "verse": 35}
            ],
            "prayer_guide": "하나님, 너무 슬픕니다. 이 아픔을 주님께 드립니다. 위로해 주세요. 아멘.",
            "youtube_keywords": ["슬플 때 찬양", "위로 설교"],
            "youtube_curated": []
          }
        },
        {"id": "sadness_loneliness", "label": "외로움", "icon": "person_outline", "response": {}},
        {"id": "sadness_failure", "label": "실패감", "icon": "trending_down", "response": {}},
        {"id": "sadness_betrayal", "label": "배신당한 아픔", "icon": "heart_broken", "response": {}}
      ]
    },
    {
      "id": "relationship",
      "emoji": "💔",
      "label": "관계의 어려움",
      "color": "#A67B5B",
      "situations": [
        {"id": "rel_family", "label": "가족 갈등", "icon": "family_restroom", "response": {}},
        {"id": "rel_friend", "label": "친구 문제", "icon": "people_outline", "response": {}},
        {"id": "rel_church", "label": "교회 내 갈등", "icon": "church", "response": {}},
        {"id": "rel_forgiveness", "label": "용서가 어려움", "icon": "handshake", "response": {}}
      ]
    },
    {
      "id": "gratitude",
      "emoji": "🙏",
      "label": "감사",
      "color": "#C9A96E",
      "situations": [
        {"id": "grat_daily", "label": "일상의 감사", "icon": "wb_sunny", "response": {}},
        {"id": "grat_answer", "label": "기도 응답", "icon": "celebration", "response": {}},
        {"id": "grat_recovery", "label": "회복의 감사", "icon": "healing", "response": {}}
      ]
    },
    {
      "id": "anger",
      "emoji": "😤",
      "label": "분노",
      "color": "#C97B5B",
      "situations": [
        {"id": "anger_injustice", "label": "불의에 대한 분노", "icon": "gavel", "response": {}},
        {"id": "anger_hurt", "label": "상처받은 분노", "icon": "flash_on", "response": {}},
        {"id": "anger_self", "label": "나 자신에게 화남", "icon": "person_off", "response": {}}
      ]
    },
    {
      "id": "tired",
      "emoji": "😴",
      "label": "지침",
      "color": "#8B9D83",
      "situations": [
        {"id": "tired_burnout", "label": "번아웃", "icon": "battery_alert", "response": {}},
        {"id": "tired_spiritual", "label": "영적 메마름", "icon": "water_drop", "response": {}},
        {"id": "tired_overwhelmed", "label": "일이 너무 많음", "icon": "inbox", "response": {}}
      ]
    },
    {
      "id": "sleepless",
      "emoji": "🌙",
      "label": "잠이 안 올 때",
      "color": "#5B6B7B",
      "situations": [
        {"id": "sleep_worry", "label": "걱정이 많아서", "icon": "psychology", "response": {}},
        {"id": "sleep_mind", "label": "생각이 멈추지 않아서", "icon": "lightbulb", "response": {}},
        {"id": "sleep_peace", "label": "평안이 필요해서", "icon": "nights_stay", "response": {}}
      ]
    },
    {
      "id": "joy",
      "emoji": "😊",
      "label": "기쁨",
      "color": "#C9A96E",
      "situations": [
        {"id": "joy_praise", "label": "찬양하고 싶을 때", "icon": "music_note", "response": {}},
        {"id": "joy_testimony", "label": "간증하고 싶을 때", "icon": "record_voice_over", "response": {}}
      ]
    },
    {
      "id": "lost",
      "emoji": "❓",
      "label": "방향 상실",
      "color": "#7B8FA1",
      "situations": [
        {"id": "lost_career", "label": "진로/직업", "icon": "work_outline", "response": {}},
        {"id": "lost_faith", "label": "믿음의 회의", "icon": "question_mark", "response": {}},
        {"id": "lost_purpose", "label": "삶의 의미", "icon": "explore", "response": {}}
      ]
    },
    {
      "id": "courage",
      "emoji": "💪",
      "label": "용기가 필요할 때",
      "color": "#5B7553",
      "situations": [
        {"id": "courage_challenge", "label": "새로운 도전", "icon": "flag", "response": {}},
        {"id": "courage_decision", "label": "중요한 결정", "icon": "alt_route", "response": {}},
        {"id": "courage_speak", "label": "말씀을 전할 때", "icon": "campaign", "response": {}}
      ]
    }
  ]
}
```

### 3-4. 힐링 패키지 UI

```
┌──────────────────────────────────────────────────────┐
│  ← 불안 > 미래에 대한 걱정                            │
│                                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🌿 에덴이 드리는 위로                            │ │
│  │                                                   │ │
│  │  "미래가 막막하게 느껴지시나요?                    │ │
│  │   하나님은 당신의 내일을                           │ │
│  │   이미 알고 계세요."                              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  📖 오늘의 말씀                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │  예레미야 29:11                                   │ │
│  │  "나 여호와가 너희를 향한 나의 생각을 아나니      │ │
│  │   재앙이 아니라 곧 평안이요 너희 장래에           │ │
│  │   소망을 주려 하는 생각이라"                       │ │
│  │                          [📋 복사] [📤 공유]      │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │  마태복음 6:34                                    │ │
│  │  "그러므로 내일 일을 위하여 염려하지 말라..."     │ │
│  │                          [📋 복사] [📤 공유]      │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  🎵 추천 영상                                         │
│  ┌───────────────┐ ┌───────────────┐                 │
│  │ ▶ [썸네일]     │ │ ▶ [썸네일]     │                 │
│  │ 불안할 때 찬양 │ │ 걱정 설교      │                 │
│  └───────────────┘ └───────────────┘                 │
│                                                       │
│  🙏 함께 기도해요                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  "하나님, 보이지 않는 내일이 두렵습니다.          │ │
│  │   주님이 나의 내일을 붙잡고 계심을 믿습니다.     │ │
│  │   오늘 하루도 주님께 맡깁니다. 아멘."             │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  [🔀 다른 말씀 보기]  [🏠 홈으로]                     │
└──────────────────────────────────────────────────────┘
```

### 3-5. Flutter 화면 구현 — 감정 선택 흐름

```dart
/// 1단계: 감정 대분류 선택
class EmotionCategoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: categories.map((cat) => _EmotionCard(
        emoji: cat.emoji,
        label: cat.label,
        color: Color(int.parse(cat.color.replaceFirst('#', '0xFF'))),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SituationView(category: cat)),
        ),
      )).toList(),
    );
  }
}

/// 2단계: 세부 상황 선택
class SituationView extends StatelessWidget {
  final EmotionCategory category;
  // ...

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: category.situations.length,
      itemBuilder: (_, i) {
        final sit = category.situations[i];
        return ListTile(
          leading: Icon(sit.iconData),
          title: Text(sit.label),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => HealingPackageView(situation: sit)),
          ),
        );
      },
    );
  }
}

/// 3단계: 힐링 패키지 (말씀 + 위로 + 유튜브 + 기도)
class HealingPackageView extends StatelessWidget {
  final Situation situation;
  // 서버 통신 없이, emotion_map.json에서 즉시 로드
}
```

### 3-6. On-device 매칭 알고리즘

```dart
/// 로컬 감정 매칭 서비스 — 서버 통신 없음
class EmotionMatchService {
  static final EmotionMatchService _instance = EmotionMatchService._();
  factory EmotionMatchService() => _instance;
  EmotionMatchService._();

  Map<String, dynamic>? _emotionData;

  Future<void> load() async {
    final json = await rootBundle.loadString('assets/data/emotion_map.json');
    _emotionData = jsonDecode(json);
  }

  /// 감정 대분류 목록
  List<EmotionCategory> get categories {
    return (_emotionData?['categories'] as List?)
        ?.map((c) => EmotionCategory.fromJson(c))
        .toList() ?? [];
  }

  /// 상황 ID로 힐링 패키지 조회
  HealingResponse? getResponse(String situationId) {
    for (final cat in _emotionData?['categories'] ?? []) {
      for (final sit in cat['situations'] ?? []) {
        if (sit['id'] == situationId) {
          return HealingResponse.fromJson(sit['response']);
        }
      }
    }
    return null;
  }

  /// 랜덤으로 같은 카테고리의 다른 응답 가져오기
  HealingResponse? getAlternative(String categoryId, String excludeSituationId) {
    final cat = (_emotionData?['categories'] as List?)
        ?.firstWhere((c) => c['id'] == categoryId, orElse: () => null);
    if (cat == null) return null;

    final others = (cat['situations'] as List)
        .where((s) => s['id'] != excludeSituationId && s['response']?['verses'] != null)
        .toList();
    if (others.isEmpty) return null;

    others.shuffle();
    return HealingResponse.fromJson(others.first['response']);
  }
}
```

---

## 4. 유튜브 큐레이션 허브

### 4-1. 연동 전략

```
에덴 앱에서 유튜브 영상을 직접 재생하지 않음 (API 비용 + 이용약관 문제)
대신:
  1. 검증된 채널 리스트를 앱에 내장
  2. 감정별 큐레이션된 영상 ID를 emotion_map.json에 포함
  3. 탭 시 YouTube 앱 또는 브라우저로 연결
  4. PIP(Picture-in-Picture) 지원 → 유튜브 앱이 작게 뜨고 에덴에서 계속 읽기
```

### 4-2. 검증된 채널 리스트 (curated_channels.json)

```json
{
  "channels": [
    {
      "id": "UCxxxxxx",
      "name": "마커스워십",
      "category": "worship",
      "tags": ["찬양", "예배", "은혜"],
      "thumbnail": "channels/marcus.webp",
      "verified": true
    },
    {
      "id": "UCyyyyyy",
      "name": "온누리교회",
      "category": "sermon",
      "tags": ["설교", "말씀", "묵상"],
      "verified": true
    },
    {
      "id": "UCzzzzzz",
      "name": "잔잔한 묵상 음악",
      "category": "meditation",
      "tags": ["묵상", "수면", "평안", "BGM"],
      "verified": true
    }
  ],
  "video_tags": {
    "불안": ["불안 찬양", "걱정 말아요 설교", "평안 묵상"],
    "슬픔": ["위로 찬양", "슬픔 위로 설교", "눈물 찬양"],
    "감사": ["감사 찬양", "감사 설교", "기쁨 예배"],
    "수면": ["잠잘때 듣는 찬양", "수면 성경 듣기", "잔잔한 묵상"]
  }
}
```

### 4-3. 유튜브 영상 카드 UI

```dart
/// 유튜브 추천 영상 카드
class YouTubeRecommendCard extends StatelessWidget {
  final String title;
  final String channelName;
  final String videoId;

  const YouTubeRecommendCard({
    super.key,
    required this.title,
    required this.channelName,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openYouTube(videoId),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 (유튜브 img URL)
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
                image: DecorationImage(
                  image: NetworkImage('https://img.youtube.com/vi/$videoId/mqdefault.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(channelName, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _openYouTube(String videoId) {
    // YouTube 앱으로 열기 (PIP 지원)
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
```

---

## 5. 저작권 생존 전략

### 5-1. 단계별 접근

| 단계 | 번역본 | 비용 | 시기 |
|------|--------|------|------|
| **1단계 (현재)** | 개역한글 (1961, 저작권 만료) + KJV (PD) | ₩0 | 출시 즉시 |
| **2단계** | 개역개정 (대한성서공회) | 연 ~₩100만 + DL당 수수료 | 유료 구독자 200+ 시점 |
| **3단계** | 쉬운말 성경, NIV 등 | 번역별 협의 | MAU 10,000+ 시점 |

### 5-2. 1단계 전략 — "치유 큐레이션" 포지셔닝

처음부터 "전체 성경 앱"과 경쟁하지 않습니다.

```
앱 이름:   에덴 — 당신을 천국으로 이끄는 성경책
부제:      마음 치유를 위한 365일 성경 가이드
초기 타겟:  성경 전문이 아닌, "감정별 말씀 큐레이션"에 집중
```

이 포지셔닝의 장점:
- 저작권 협의 시 "전문 사용"이 아닌 "인용 수준"으로 분류 가능성
- 대형 성경 앱과 직접 경쟁을 피하고 틈새 시장 선점
- "멘탈 헬스케어 + 성경" 카테고리 1위 노리기

---

## 6. 구현 우선순위 로드맵

### Phase 1: MVP (4주) — 감정 매칭 + 비주얼 탐색

| 주차 | 작업 | 산출물 |
|------|------|--------|
| 1주 | emotion_map.json 작성 (10개 감정 × 3~4개 상황 = 35개 매칭) | JSON 데이터 |
| 1주 | 감정 대분류/세부상황/힐링패키지 3화면 구현 | 3개 Dart 파일 |
| 2주 | 비주얼 썸네일 책 선택기 (66권 그리드) | book_grid_view.dart |
| 2주 | 장 카드 선택기 (미리보기 텍스트 포함) | chapter_card_view.dart |
| 3주 | 유튜브 큐레이션 데이터 (채널 10개, 영상 50개) | curated_channels.json |
| 3주 | 힐링 패키지에 유튜브 영상 카드 연동 | youtube_card.dart |
| 4주 | 전체 통합 테스트 + 디자인 폴리싱 | 릴리스 후보 |

### Phase 2: 고도화 (4주)

| 작업 | 설명 |
|------|------|
| 감정 매칭 확장 | 35개 → 100개 상황으로 확대 |
| 사용 패턴 학습 | 로컬에서 자주 선택하는 감정 기록 → 홈 화면 맞춤 추천 |
| 줌 네비게이션 | InteractiveViewer 기반 66권 줌인/아웃 |
| 카드 스와이프 읽기 | 좌/우 스와이프로 장 넘기기 |
| 수면 모드 | "잠이 안 올 때" → 어두운 UI + 잔잔한 찬양 + 자동 꺼짐 |

### Phase 3: 확장 (4주+)

| 작업 | 설명 |
|------|------|
| 개역개정 라이선스 | 대한성서공회 협의 |
| TypeCast 음성 | "보는 성경" + "듣는 성경" 프리미엄 |
| 커뮤니티 기능 | 감정별 익명 기도 나눔 |
| 위젯 | 홈 화면 "오늘의 감정 말씀" 위젯 |

---

## 7. 데이터 준비 체크리스트

### 즉시 작성 필요

| 파일 | 내용 | 예상 크기 |
|------|------|----------|
| `emotion_map.json` | 10개 감정 × 3~4개 상황 × (AI메시지 + 구절 2개 + 기도 + 유튜브) | ~200KB |
| `curated_channels.json` | 검증된 유튜브 채널 10개 + 영상 50개 | ~20KB |
| 66권 썸네일 이미지 | Midjourney 생성 → WebP 변환 (이미 가이드 완성) | ~60MB |

### 이미 완성된 것

| 파일 | 상태 |
|------|------|
| `bible_full.json` (66권 27,121절) | ✅ 완료 |
| `counsel_presets.json` (50개 프리셋) | ✅ 완료 → emotion_map.json으로 확장 |
| `books_index.json` (66권 메타데이터) | ✅ 완료 |
| Midjourney 프롬프트 66장 | ✅ 문서 완료 → 이미지 생성 필요 |

---

## 8. 핵심 요약 — 에덴이 이기는 방법

```
┌──────────────────────────────────────────────────────────────┐
│                                                               │
│   ❌ YouVersion과 번역본 수로 경쟁하지 않는다                 │
│   ❌ 갓피플과 기능 수로 경쟁하지 않는다                       │
│   ❌ 매일성경과 해설 품질로 경쟁하지 않는다                   │
│                                                               │
│   ✅ "내 감정을 알아주는 앱"으로 포지셔닝한다                 │
│   ✅ "탭 3번이면 위로를 받는" 속도로 승부한다                │
│   ✅ "넷플릭스처럼 보는 성경"으로 새 카테고리를 만든다       │
│   ✅ "성경 + 유튜브 + 기도"를 한 화면에 묶는다              │
│                                                               │
│   슬로건: "성경 앱이 아니라,                                  │
│            성경을 도구로 쓰는 멘탈 헬스케어 앱"               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

**문서 끝 | 프로젝트 에덴 · 차별화 UX · 버튼형 AI · 유튜브 연동 개발 설계서 v1.0**
