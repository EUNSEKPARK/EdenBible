import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';

/// 성경 전문 검색 화면
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _bible = BibleDataService();
  List<BibleVerse> _results = [];
  bool _searching = false;
  String _lastQuery = '';

  // 인기 검색어
  final _popularSearches = ['사랑', '평안', '소망', '믿음', '은혜', '기도', '용서', '감사', '지혜', '축복'];

  void _search(String query) {
    if (query.trim().isEmpty || query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _searching = true);

    // 비동기로 검색 (UI 블로킹 방지)
    Future.microtask(() {
      final results = _bible.search(query, limit: 100);
      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? EdenColors.backgroundDark : EdenColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ─── 검색 헤더 ───
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF0EEE8),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: EdenColors.textTertiaryLight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                hintText: '성경 구절 검색...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 15),
                              onSubmitted: _search,
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() {
                                  _results = [];
                                  _lastQuery = '';
                                });
                              },
                              child: Icon(Icons.close_rounded, size: 18, color: EdenColors.textTertiaryLight),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── 검색 결과 or 인기 검색어 ───
            Expanded(
              child: _results.isEmpty && !_searching
                  ? _buildSuggestions(isDark)
                  : _searching
                      ? const Center(child: CircularProgressIndicator())
                      : _buildResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('인기 검색어', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.secondary, letterSpacing: 2)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((keyword) => GestureDetector(
              onTap: () {
                _controller.text = keyword;
                _search(keyword);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(keyword, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text('검색 팁', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EdenColors.secondary, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text('키워드를 입력하면 개역한글 전체에서 검색합니다.\n예: "사랑", "평안", "여호와"', style: TextStyle(fontSize: 14, color: EdenColors.textSecondaryLight, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text('${_results.length}개 구절 발견', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EdenColors.secondary)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _results.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final verse = _results[index];
              return _SearchResultTile(verse: verse, query: _lastQuery, isDark: isDark);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _SearchResultTile extends StatelessWidget {
  final BibleVerse verse;
  final String query;
  final bool isDark;
  const _SearchResultTile({required this.verse, required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 참조
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 14, color: EdenColors.primary),
              const SizedBox(width: 6),
              Text(verse.refKo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EdenColors.primary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: EdenColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(verse.category, style: TextStyle(fontSize: 10, color: EdenColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 본문 (검색어 하이라이트)
          _HighlightedText(text: verse.krv, query: query, isDark: isDark),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final bool isDark;
  const _HighlightedText({required this.text, required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight));
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(color: EdenColors.primary, fontWeight: FontWeight.w700, backgroundColor: EdenColors.primary.withValues(alpha: 0.1)),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight),
        children: spans,
      ),
    );
  }
}
