import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';

/// 성경 필사 화면 — 구절을 보며 직접 타이핑하여 필사
class TranscriptionView extends StatefulWidget {
  const TranscriptionView({super.key});

  @override
  State<TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  final _bible = BibleDataService();
  final _settings = SettingsService();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  int _bookId = 19;  // 시편부터 시작
  int _chapter = 23;
  int _currentVerse = 0;
  List<BibleVerse> _verses = [];
  bool _completed = false;
  int _correctCount = 0;
  int _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  void _loadVerses() {
    setState(() {
      _verses = _bible.getVerses(_bookId, _chapter);
      _currentVerse = 0;
      _completed = false;
      _correctCount = 0;
      _totalAttempts = 0;
      _controller.clear();
    });
  }

  void _checkAndNext() {
    if (_verses.isEmpty || _currentVerse >= _verses.length) return;

    final input = _controller.text.trim();
    final original = _verses[_currentVerse].krv.trim();
    _totalAttempts++;

    // 정확도 체크 (공백/구두점 무시)
    final normalizedInput = input.replaceAll(RegExp(r'[\s.,!?;:~\-]'), '');
    final normalizedOriginal = original.replaceAll(RegExp(r'[\s.,!?;:~\-]'), '');

    if (normalizedInput == normalizedOriginal) {
      _correctCount++;
    }

    setState(() {
      _controller.clear();
      if (_currentVerse < _verses.length - 1) {
        _currentVerse++;
      } else {
        _completed = true;
      }
    });

    _focusNode.requestFocus();
  }

  BibleVerse? get _currentVerseData =>
      _verses.isNotEmpty && _currentVerse < _verses.length ? _verses[_currentVerse] : null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _bible.books.isNotEmpty
        ? _bible.books.firstWhere((b) => b.id == _bookId, orElse: () => _bible.books.first)
        : null;

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      appBar: AppBar(
        title: Text('필사 — ${book?.nameKo ?? ''} $_chapter장'),
        centerTitle: true,
        actions: [
          // 장 변경 버튼
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => _showChapterPicker(context),
          ),
        ],
      ),
      body: _completed ? _buildCompletionView(isDark) : _buildTranscriptionView(isDark),
    );
  }

  Widget _buildTranscriptionView(bool isDark) {
    final verse = _currentVerseData;
    if (verse == null) return const Center(child: CircularProgressIndicator());

    final progress = _verses.isNotEmpty ? (_currentVerse + 1) / _verses.length : 0.0;

    return Column(
      children: [
        // 진행률
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentVerse + 1} / ${_verses.length}절', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EdenColors.primary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8),
              valueColor: AlwaysStoppedAnimation(EdenColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 원문 표시
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? EdenColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('${verse.verse}절', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EdenColors.primary)),
                    ),
                    const Spacer(),
                    Text(verse.shortRef, style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      verse.krv,
                      style: TextStyle(fontSize: _settings.fontSize, height: 1.8, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 필사 입력 영역
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: EdenColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('위 말씀을 그대로 적어보세요', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EdenColors.secondary, letterSpacing: 1)),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: '여기에 필사하세요...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: _settings.fontSize * 0.9, height: 1.8),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 다음 절 버튼
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAndNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _currentVerse < _verses.length - 1 ? '다음 절로 →' : '필사 완료',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView(bool isDark) {
    final accuracy = _totalAttempts > 0 ? (_correctCount / _totalAttempts * 100).toInt() : 0;
    final book = _bible.books.firstWhere((b) => b.id == _bookId);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 80, color: EdenColors.primary),
            const SizedBox(height: 24),
            const Text('필사 완료!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${book.nameKo} $_chapter장을 모두 필사했습니다', style: TextStyle(fontSize: 15, color: EdenColors.textSecondaryLight)),
            const SizedBox(height: 32),

            // 통계
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? EdenColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(value: '${_verses.length}', label: '필사한 절'),
                  Container(width: 1, height: 40, color: Colors.black.withValues(alpha: 0.05)),
                  _StatItem(value: '$accuracy%', label: '정확도'),
                  Container(width: 1, height: 40, color: Colors.black.withValues(alpha: 0.05)),
                  _StatItem(value: '$_correctCount', label: '정확 일치'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                _loadVerses(); // 같은 장 다시 필사
              },
              child: const Text('다시 필사하기'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 500,
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('필사할 장 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('추천: 시편, 잠언, 전도서', style: TextStyle(fontSize: 13, color: EdenColors.textSecondaryLight)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _ChapterOption(title: '시편 23편 (여호와는 나의 목자)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 19; _chapter = 23; }); _loadVerses(); }),
                    _ChapterOption(title: '시편 91편 (지존자의 은밀한 곳)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 19; _chapter = 91; }); _loadVerses(); }),
                    _ChapterOption(title: '시편 121편 (내가 산을 향하여)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 19; _chapter = 121; }); _loadVerses(); }),
                    _ChapterOption(title: '잠언 3장 (마음을 다하여)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 20; _chapter = 3; }); _loadVerses(); }),
                    _ChapterOption(title: '전도서 3장 (천하에 범사가)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 21; _chapter = 3; }); _loadVerses(); }),
                    _ChapterOption(title: '이사야 40장 (위로하라)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 23; _chapter = 40; }); _loadVerses(); }),
                    _ChapterOption(title: '마태복음 5장 (산상수훈)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 40; _chapter = 5; }); _loadVerses(); }),
                    _ChapterOption(title: '요한복음 1장 (태초에 말씀이)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 43; _chapter = 1; }); _loadVerses(); }),
                    _ChapterOption(title: '고린도전서 13장 (사랑은)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 46; _chapter = 13; }); _loadVerses(); }),
                    _ChapterOption(title: '빌립보서 4장 (기뻐하라)', onTap: () { Navigator.pop(ctx); setState(() { _bookId = 50; _chapter = 4; }); _loadVerses(); }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: EdenColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: EdenColors.textTertiaryLight, letterSpacing: 1)),
      ],
    );
  }
}

class _ChapterOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _ChapterOption({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.edit_note_rounded, color: EdenColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: EdenColors.textTertiaryLight),
      onTap: onTap,
    );
  }
}
