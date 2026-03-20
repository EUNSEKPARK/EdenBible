# Midjourney 이미지 생성 프롬프트 가이드

**문서 버전:** v1.0  
**작성일:** 2026-03-19  
**목적:** 성경 66권에 대한 Midjourney 이미지를 일관된 스타일로 생성하기 위한 프롬프트 시스템

---

## 1. 스타일 통일 원칙

모든 이미지는 **에덴 성경책의 Sage Green + Warm Gold 컬러 팔레트**에 맞춰 일관된 톤을 유지합니다.

### 1-1. 마스터 스타일 프리픽스 (모든 프롬프트에 공통 적용)

```
Soft watercolor painting, muted earth tones, sage green and warm gold palette,
gentle brushstrokes, spiritual atmosphere, minimal composition,
soft natural lighting, contemplative mood --ar 3:4 --s 250 --q 2
```

### 1-2. 색상 팔레트 참조

| 컬러 | Hex | 용도 |
|------|-----|------|
| Sage Green (Primary) | #5B7553 | 자연, 평화 장면 |
| Warm Gold (Accent) | #C9A96E | 신성, 영광 장면 |
| Warm Cream (Background) | #FFFDF7 | 하늘, 배경 |
| Primary Dark | #3D5238 | 그림자, 깊이 |
| Muted Sage | #8B9D83 | 보조 톤 |

### 1-3. 금지 요소 (Negative Prompt)

```
--no photorealistic, 3D render, neon colors, dark horror, blood, violence,
modern clothing, technology, cartoon style, anime, pixel art
```

---

## 2. 이미지 카테고리별 프롬프트

### 2-1. 책 대표 이미지 (66장) — `480×640`

각 책의 핵심 주제나 상징적 장면을 1장의 이미지로 표현합니다.

#### 모세오경 (1~5)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 1 | 창세기 | `A serene Garden of Eden with lush trees and a flowing river, soft morning light filtering through leaves, sage green and gold tones, watercolor painting style --ar 3:4 --s 250` |
| 2 | 출애굽기 | `Moses standing before a burning bush in a desert landscape, warm golden flames against sage green hills, watercolor style, spiritual atmosphere --ar 3:4 --s 250` |
| 3 | 레위기 | `A sacred altar with gentle smoke rising upward, olive branches and wheat nearby, muted earth tones, watercolor painting --ar 3:4 --s 250` |
| 4 | 민수기 | `A vast desert landscape with a distant camp of tents, pillar of cloud on horizon, warm gold and sage green palette, watercolor --ar 3:4 --s 250` |
| 5 | 신명기 | `Moses overlooking a promised land from a mountaintop, rolling green hills below, golden sunset sky, watercolor style --ar 3:4 --s 250` |

#### 역사서 (6~17)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 6 | 여호수아 | `A river parting with dry ground between waters, green banks on both sides, golden light from above, watercolor painting --ar 3:4 --s 250` |
| 7 | 사사기 | `A lone warrior with a torch in a dark field, warm golden firelight, sage green shadows, watercolor style --ar 3:4 --s 250` |
| 8 | 룻기 | `A woman gleaning wheat in a golden field at sunset, sage green hills behind, soft watercolor tones --ar 3:4 --s 250` |
| 9 | 사무엘상 | `A shepherd boy with a sling in a meadow, sheep nearby, soft golden hour light, sage green grass, watercolor --ar 3:4 --s 250` |
| 10 | 사무엘하 | `A crown resting on a stone throne, olive branches around it, warm gold and sage green, watercolor style --ar 3:4 --s 250` |
| 11 | 열왕기상 | `A magnificent temple with golden roof among green hills, soft clouds, watercolor painting style --ar 3:4 --s 250` |
| 12 | 열왕기하 | `A chariot ascending to heaven with fire, sage green landscape below, warm gold flames, watercolor --ar 3:4 --s 250` |
| 13 | 역대상 | `Ancient scrolls and genealogy records on a wooden table, soft candlelight, sage green cloth, watercolor --ar 3:4 --s 250` |
| 14 | 역대하 | `A grand temple interior with golden light streaming through windows, sage green curtains, watercolor --ar 3:4 --s 250` |
| 15 | 에스라 | `People rebuilding a stone wall together, sunrise in background, sage green and gold tones, watercolor --ar 3:4 --s 250` |
| 16 | 느헤미야 | `A fortified city gate being rebuilt, workers with determination, warm golden sunrise, watercolor style --ar 3:4 --s 250` |
| 17 | 에스더 | `A queen in elegant robes in a palace garden, sage green foliage, warm golden accents, watercolor --ar 3:4 --s 250` |

#### 시가서 (18~22)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 18 | 욥기 | `A solitary figure sitting in ashes under a vast starry sky, muted sage green and gold tones, watercolor painting --ar 3:4 --s 250` |
| 19 | 시편 | `A shepherd with a harp beside still waters, green pastures, golden sunset reflection, watercolor style --ar 3:4 --s 250` |
| 20 | 잠언 | `An open ancient book on a stone table with olive branches, soft golden light, sage green background, watercolor --ar 3:4 --s 250` |
| 21 | 전도서 | `A sundial casting shadow in a garden, withering and blooming flowers together, sage green and gold, watercolor --ar 3:4 --s 250` |
| 22 | 아가 | `A blooming garden with roses and lilies, soft morning dew, warm gold and sage green palette, watercolor --ar 3:4 --s 250` |

#### 대선지서 (23~27)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 23 | 이사야 | `A peaceful lion lying down with a lamb in a green meadow, golden light from above, watercolor painting --ar 3:4 --s 250` |
| 24 | 예레미야 | `A solitary figure weeping under a tree, rain falling softly, muted sage green tones, watercolor style --ar 3:4 --s 250` |
| 25 | 예레미야애가 | `Ruins of a city with a single flower growing from rubble, sage green and dusty gold, watercolor --ar 3:4 --s 250` |
| 26 | 에스겔 | `A valley of dry bones with light breaking through clouds above, sage green hills, golden rays, watercolor --ar 3:4 --s 250` |
| 27 | 다니엘 | `A person standing unharmed among lions in a den, warm golden light protecting them, watercolor style --ar 3:4 --s 250` |

#### 소선지서 (28~39)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 28 | 호세아 | `A faithful figure waiting at a crossroads, olive trees lining the path, warm gold sunset, watercolor --ar 3:4 --s 250` |
| 29 | 요엘 | `Locusts over a field transforming into rain and harvest, sage green and gold transition, watercolor --ar 3:4 --s 250` |
| 30 | 아모스 | `A plumb line hanging beside a stone wall, simple fig trees nearby, earth tones, watercolor style --ar 3:4 --s 250` |
| 31 | 오바댜 | `An eagle's nest on a high cliff with sage green valleys below, golden sky, watercolor painting --ar 3:4 --s 250` |
| 32 | 요나 | `A small boat on a vast ocean under stormy clouds breaking to reveal golden light, watercolor style --ar 3:4 --s 250` |
| 33 | 미가 | `A peaceful village with every person under their own vine and fig tree, sage green and gold, watercolor --ar 3:4 --s 250` |
| 34 | 나훔 | `A mighty river flowing through ancient ruins, sage green banks, warm reflections, watercolor --ar 3:4 --s 250` |
| 35 | 하박국 | `A watchtower on a hill overlooking green valleys at dawn, warm gold sunrise, watercolor painting --ar 3:4 --s 250` |
| 36 | 스바냐 | `A quiet city at dawn with first light breaking through clouds, sage green rooftops, watercolor --ar 3:4 --s 250` |
| 37 | 학개 | `Foundation stones of a temple being laid, workers in morning light, sage green and gold, watercolor --ar 3:4 --s 250` |
| 38 | 스가랴 | `A golden lampstand with seven lights among olive trees, sage green background, watercolor style --ar 3:4 --s 250` |
| 39 | 말라기 | `A sunrise over a horizon with the sun of righteousness rising, warm gold rays, sage green earth, watercolor --ar 3:4 --s 250` |

#### 복음서 (40~43)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 40 | 마태복음 | `A figure teaching on a hillside with crowds below, sage green grass, warm golden light, watercolor painting --ar 3:4 --s 250` |
| 41 | 마가복음 | `Footprints on a dusty road leading forward, sage green fields on sides, warm gold horizon, watercolor --ar 3:4 --s 250` |
| 42 | 누가복음 | `A manger scene with a star above, warm golden glow, sage green stable elements, gentle watercolor --ar 3:4 --s 250` |
| 43 | 요한복음 | `A bright light emanating from an open doorway into darkness, warm gold and sage green tones, watercolor style --ar 3:4 --s 250` |

#### 바울서신~일반서신 (44~65)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 44 | 사도행전 | `Tongues of gentle fire descending on a group of people, warm gold flames, sage green robes, watercolor --ar 3:4 --s 250` |
| 45 | 로마서 | `A road leading from darkness to light, stone pathway, sage green landscape, golden destination, watercolor --ar 3:4 --s 250` |
| 46 | 고린도전서 | `A mirror reflecting light, love symbol with olive branches, warm gold and sage green, watercolor --ar 3:4 --s 250` |
| 47 | 고린도후서 | `Broken pottery being repaired with gold (kintsugi style), sage green cloth, watercolor painting --ar 3:4 --s 250` |
| 48 | 갈라디아서 | `Broken chains falling away in golden light, sage green freedom landscape, watercolor style --ar 3:4 --s 250` |
| 49 | 에베소서 | `A complete set of ancient armor bathed in golden light, sage green backdrop, watercolor painting --ar 3:4 --s 250` |
| 50 | 빌립보서 | `A joyful sunrise over a prison courtyard, sage green vines growing on walls, warm gold sky, watercolor --ar 3:4 --s 250` |
| 51 | 골로새서 | `A crown above all things with rays of light, sage green earth below, warm gold sky, watercolor --ar 3:4 --s 250` |
| 52 | 데살로니가전서 | `Clouds parting with golden light descending, sage green fields below, watercolor painting --ar 3:4 --s 250` |
| 53 | 데살로니가후서 | `An hourglass with golden sand, sage green table, soft light, watercolor style --ar 3:4 --s 250` |
| 54 | 디모데전서 | `A torch being passed from one hand to another, warm golden flame, sage green background, watercolor --ar 3:4 --s 250` |
| 55 | 디모데후서 | `An athlete crossing a finish line with arms raised, warm gold light, sage green field, watercolor --ar 3:4 --s 250` |
| 56 | 디도서 | `An island coastline with olive trees and a white church, sage green and warm gold, watercolor --ar 3:4 --s 250` |
| 57 | 빌레몬서 | `Two hands clasping in reconciliation, warm golden light between them, sage green fabric, watercolor --ar 3:4 --s 250` |
| 58 | 히브리서 | `An ancient altar transforming into a cross, warm gold light, sage green curtain tearing, watercolor --ar 3:4 --s 250` |
| 59 | 야고보서 | `A calm sea reflecting golden sunset, sage green shore, a single tree standing firm, watercolor --ar 3:4 --s 250` |
| 60 | 베드로전서 | `A cornerstone glowing with warm gold among sage green stones, watercolor painting style --ar 3:4 --s 250` |
| 61 | 베드로후서 | `A new dawn breaking over mountains, sage green valleys, warm golden sky, watercolor --ar 3:4 --s 250` |
| 62 | 요한일서 | `A warm golden light filling a dark room through a window, sage green curtain, watercolor style --ar 3:4 --s 250` |
| 63 | 요한이서 | `A sealed letter with a wax seal on sage green cloth, warm candlelight, watercolor --ar 3:4 --s 250` |
| 64 | 요한삼서 | `An open door welcoming travelers on a sage green path, warm golden doorway light, watercolor --ar 3:4 --s 250` |
| 65 | 유다서 | `A lighthouse beam cutting through fog, sage green cliffs, warm gold light, watercolor painting --ar 3:4 --s 250` |

#### 요한계시록 (66)

| 책 ID | 책 이름 | 프롬프트 |
|-------|---------|---------|
| 66 | 요한계시록 | `A glorious new city descending from golden clouds, crystal river flowing through sage green paradise, watercolor painting, breathtaking beauty --ar 3:4 --s 250` |

---

### 2-2. 오늘의 말씀 배경 (30장) — `720×960`

오늘의 말씀 30개 구절에 대한 분위기 배경 이미지입니다.

**공통 서픽스:**
```
soft bokeh background, text-friendly negative space on center,
watercolor painting, sage green and warm gold --ar 3:4 --s 300
```

| # | 구절 | 프롬프트 키워드 |
|---|------|---------------|
| 1 | 시편 23:1 | `green pastures beside still waters, shepherd's staff` |
| 2 | 요한복음 3:16 | `a glowing cross on a hill at golden hour` |
| 3 | 이사야 41:10 | `a hand reaching down from golden clouds` |
| 4 | 빌립보서 4:13 | `a mountain peak with golden sunrise` |
| 5 | 예레미야 29:11 | `an open road leading to a bright horizon` |
| 6 | 로마서 8:28 | `puzzle pieces coming together in golden light` |
| 7 | 잠언 3:5 | `a winding forest path with dappled light` |
| 8 | 시편 46:1 | `a fortress on a rock amid calm waters` |
| 9 | 마태복음 11:28 | `a resting place under a great tree, shade` |
| 10 | 이사야 40:31 | `an eagle soaring above sage green mountains` |
| 11 | 시편 27:1 | `a lantern glowing in soft darkness` |
| 12 | 갈라디아서 2:20 | `an empty cross with sunrise behind it` |
| 13 | 여호수아 1:9 | `footsteps in sand leading forward confidently` |
| 14 | 시편 119:105 | `a lamp illuminating a stone path at night` |
| 15 | 디모데후서 1:7 | `a flame that cannot be extinguished in wind` |
| 16 | 신명기 31:8 | `two sets of footprints becoming one on a beach` |
| 17 | 요한복음 14:27 | `a dove carrying an olive branch over water` |
| 18 | 시편 37:4 | `a blooming garden at golden hour` |
| 19 | 로마서 15:13 | `a rainbow after rain over green hills` |
| 20 | 빌립보서 4:6 | `folded hands in prayer with golden light` |
| 21 | 요한일서 4:18 | `warm golden embrace of light dispelling shadows` |
| 22 | 시편 34:18 | `a broken vessel being mended with gold` |
| 23 | 고린도후서 5:17 | `a butterfly emerging from a cocoon in morning light` |
| 24 | 마태복음 6:34 | `wildflowers in a field, not worried, just blooming` |
| 25 | 히브리서 13:5 | `a cabin with warm light in a snowy sage landscape` |
| 26 | 시편 139:14 | `a newborn leaf unfurling with dewdrops` |
| 27 | 이사야 43:19 | `a stream appearing in a desert, new growth` |
| 28 | 고린도전서 10:13 | `a bridge over a chasm with golden handrails` |
| 29 | 야고보서 1:5 | `an open book under a wise old tree` |
| 30 | 시편 55:22 | `heavy stones being lifted by invisible hands into light` |

---

### 2-3. 공유카드 배경 (10장) — `1080×1350`

SNS 공유용 고해상도 배경. 텍스트 오버레이가 들어가므로 **중앙 여백이 넉넉**해야 합니다.

**공통 서픽스:**
```
large text-friendly negative space in center,
subtle texture, watercolor, sage green and warm gold,
elegant and minimal --ar 3:4 --s 350 --q 2
```

| # | 테마 | 프롬프트 키워드 |
|---|------|---------------|
| 1 | 새벽 기도 | `dawn sky gradient from dark blue to warm gold, misty hills` |
| 2 | 초록 목장 | `peaceful green meadow with morning dew, soft light` |
| 3 | 바다 평화 | `calm ocean at golden hour, gentle waves` |
| 4 | 산 정상 | `mountain summit above clouds, golden light above` |
| 5 | 올리브 나무 | `ancient olive tree with golden sunlight filtering through` |
| 6 | 밤하늘 별 | `starry night sky with warm gold constellations, sage tones` |
| 7 | 꽃밭 | `wildflower field in sage green and gold palette` |
| 8 | 폭포와 강 | `gentle waterfall into a still pool, green moss` |
| 9 | 가을 수확 | `golden wheat field at sunset, sage green borders` |
| 10 | 겨울 고요 | `snow-covered sage green pine forest, warm gold sunbeam` |

---

## 3. 생성 워크플로우

### 3-1. Midjourney 생성 순서

```
Phase 1: 책 대표 이미지 66장
  → 하루 ~10장씩 약 1주

Phase 2: 오늘의 말씀 배경 30장
  → 하루 ~10장씩 약 3일

Phase 3: 공유카드 배경 10장
  → 1일

Phase 4: 장 단위 장면 이미지 (팩별)
  → 점진적 확장, 수 주~수 개월
```

### 3-2. 생성 후 처리

```bash
# 1. Midjourney에서 다운로드 (원본 PNG)

# 2. WebP 변환 + 리사이즈
# 책 대표 (480x640)
for f in raw/books/*.png; do
  cwebp -q 75 -resize 480 640 "$f" -o "processed/books/$(basename ${f%.png}.webp)"
done

# 오늘의 말씀 (720x960)
for f in raw/daily/*.png; do
  cwebp -q 80 -resize 720 960 "$f" -o "processed/daily/$(basename ${f%.png}.webp)"
done

# 공유카드 (1080x1350)
for f in raw/share/*.png; do
  cwebp -q 85 -resize 1080 1350 "$f" -o "processed/share/$(basename ${f%.png}.webp)"
done

# 3. 파일 네이밍 (books_index.json의 id에 맞게)
# 01.webp = 창세기, 02.webp = 출애굽기, ...

# 4. assets 폴더로 복사
cp processed/books/*.webp ../EdenBible/assets/images/books/
cp processed/daily/*.webp ../EdenBible/assets/images/daily/
cp processed/share/*.webp ../EdenBible/assets/images/share/
```

### 3-3. cwebp 설치

```bash
# macOS
brew install webp

# Ubuntu
sudo apt install webp
```

---

## 4. Midjourney 이용약관 체크리스트

| 항목 | 확인 사항 |
|------|----------|
| 상업적 사용 | Pro 플랜 이상에서 상업적 사용 가능 |
| 앱 배포 | AI 생성 이미지를 앱에 포함하여 배포 가능 |
| 저작권 | Midjourney Pro 이상 사용자에게 생성 이미지 소유권 부여 |
| 표기 의무 | 일반적으로 표기 불필요 (Pro 이상), 약관 최신 확인 권장 |
| 민감 콘텐츠 | 성경의 폭력적/선정적 장면은 생성 자제 |
| 일관성 | 동일 프롬프트 프리픽스를 사용하되 --seed 값으로 스타일 고정 시도 |

> 반드시 생성 시점의 최신 Midjourney Terms of Service를 확인하세요.
> https://docs.midjourney.com/docs/terms-of-service

---

## 5. 품질 관리 기준

| 기준 | 합격 | 불합격 |
|------|------|--------|
| 색상 톤 | Sage Green + Warm Gold 계열 | 네온, 원색, 과도한 채도 |
| 구도 | 중앙 여백 충분 (텍스트 오버레이 가능) | 복잡한 구도, 여백 없음 |
| 해상도 | 지정 해상도 이상 | 블러, 저해상도 |
| 문화적 적절성 | 경건하고 평화로운 분위기 | 폭력, 선정, 공포 |
| 스타일 일관성 | 수채화 톤 유지 | 사실적 사진, 3D, 만화 |
| 성경 정확성 | 해당 책/장면과 관련 있는 이미지 | 무관한 이미지 |

---

**문서 끝 | 프로젝트 에덴 · Midjourney 이미지 생성 프롬프트 가이드 v1.0**