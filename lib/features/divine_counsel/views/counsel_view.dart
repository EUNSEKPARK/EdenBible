import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/counsel_preset.dart';
import '../../../core/services/counsel_service.dart';

class CounselView extends StatefulWidget {
  const CounselView({super.key});
  @override
  State<CounselView> createState() => _CounselViewState();
}

class _CounselViewState extends State<CounselView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _counsel = CounselService();
  final _messages = <_ChatMessage>[];
  bool _isTyping = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _suggestions = _counsel.getSuggestionQuestions();
    _messages.add(_ChatMessage(isUser: false, text: '안녕하세요, 오늘 마음이 어떠세요?\n편하게 이야기해 주세요.', verses: [], prayerGuide: null));
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text.trim(), verses: [], prayerGuide: null));
      _isTyping = true;
      // 추천 질문 갱신
      _suggestions = _counsel.getSuggestionQuestions();
    });
    _scrollToBottom();

    // 타이핑 효과 (0.5~1.2초 랜덤)
    await Future.delayed(Duration(milliseconds: 500 + (text.length * 20).clamp(0, 700)));

    final response = _counsel.findBestMatch(text);
    setState(() {
      _isTyping = false;
      if (response != null) {
        final verseTexts = _counsel.getVerseTexts(response.verses);
        _messages.add(_ChatMessage(isUser: false, text: response.message, verses: verseTexts, prayerGuide: response.prayerGuide));
      } else {
        _messages.add(_ChatMessage(isUser: false, text: '마음을 나눠주셔서 감사해요. "불안", "슬픔", "감사" 같은 감정을 알려주시면 맞춤 말씀을 찾아드릴게요.', verses: [], prayerGuide: null));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(children: [
      // 추천 질문 칩 (대화 5턴 이하일 때 표시)
      if (_messages.length <= 6)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(children: _suggestions.map((q) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(q, style: TextStyle(fontSize: 15, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight)),
              backgroundColor: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE),
              side: BorderSide.none,
              onPressed: () => _sendMessage(q),
            ),
          )).toList()),
        ),
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length && _isTyping) return _TypingIndicator(isDark: isDark);
            final msg = _messages[index];
            return msg.isUser ? _UserBubble(message: msg, isDark: isDark) : _AiBubble(message: msg, isDark: isDark);
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(color: isDark ? EdenColors.surfaceDark : Colors.white, border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
        child: SafeArea(top: false, child: Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(24)),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: '메시지를 입력하세요...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
              style: const TextStyle(fontSize: 17),
              onSubmitted: _sendMessage,
              textInputAction: TextInputAction.send,
            ),
          )),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(width: 44, height: 44, decoration: BoxDecoration(color: EdenColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22)),
          ),
        ])),
      ),
    ]);
  }

  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }
}

class _ChatMessage {
  final bool isUser; final String text; final List<Map<String, String>> verses; final String? prayerGuide;
  _ChatMessage({required this.isUser, required this.text, required this.verses, this.prayerGuide});
}

class _TypingIndicator extends StatelessWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: Container(
    margin: const EdgeInsets.only(bottom: 16, right: 100), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: EdenColors.secondary.withValues(alpha: 0.4))))),
  ));
}

class _UserBubble extends StatelessWidget {
  final _ChatMessage message; final bool isDark;
  const _UserBubble({required this.message, required this.isDark});
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerRight, child: Container(
    margin: const EdgeInsets.only(bottom: 16, left: 60), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: const BoxDecoration(color: EdenColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(4))),
    child: Text(message.text, style: const TextStyle(fontSize: 17, color: Colors.white, height: 1.5)),
  ));
}

class _AiBubble extends StatelessWidget {
  final _ChatMessage message; final bool isDark;
  const _AiBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.only(bottom: 16, right: 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 6, left: 4), child: Row(children: [
          Icon(Icons.auto_awesome, size: 14, color: EdenColors.accent), const SizedBox(width: 6),
          Text('에덴', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EdenColors.accent, letterSpacing: 1)),
        ])),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? EdenColors.surfaceVariantDark : const Color(0xFFF5F3EE),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message.text, style: TextStyle(fontSize: 17, color: isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight, height: 1.6)),
            ...message.verses.map((v) => Container(
              width: double.infinity, margin: const EdgeInsets.only(top: 14), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: EdenColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: EdenColors.primary.withValues(alpha: 0.15))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.menu_book_rounded, size: 14, color: EdenColors.primary), const SizedBox(width: 6), Text(v['ref'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EdenColors.primary))]),
                const SizedBox(height: 8),
                Text(v['text'] ?? '', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: (isDark ? EdenColors.textPrimaryDark : EdenColors.textPrimaryLight).withValues(alpha: 0.8), height: 1.6)),
              ]),
            )),
            if (message.prayerGuide != null) ...[
              const SizedBox(height: 14),
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: EdenColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('함께 기도해요', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EdenColors.accent, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(message.prayerGuide!, style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.6, color: isDark ? EdenColors.textSecondaryDark : EdenColors.textSecondaryLight)),
                ])),
            ],
          ]),
        ),
        Padding(padding: const EdgeInsets.only(top: 6, left: 4), child: Row(children: [
          GestureDetector(
            onTap: () {
              final text = message.verses.isNotEmpty ? '"${message.verses.first['text']}"\n\n${message.verses.first['ref']}\n\n- 에덴 성경책' : message.text;
              Share.share(text);
            },
            child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.share_outlined, size: 16, color: EdenColors.secondary)),
          ),
        ])),
      ]),
    ));
  }
}
