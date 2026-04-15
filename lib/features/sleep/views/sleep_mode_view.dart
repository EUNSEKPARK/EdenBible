import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/colors.dart';
import '../../../core/models/bible_verse.dart';
import '../../../core/services/bible_data_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/tts_service.dart';

/// P3-01: 수면 묵상 모드 — 다크 UI + 자동 넘김 + 타이머 + TTS
class SleepModeView extends StatefulWidget {
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onClose;
  const SleepModeView({super.key, this.onToggleFullscreen, this.onClose});
  @override
  State<SleepModeView> createState() => _SleepModeViewState();
}

class _SleepModeViewState extends State<SleepModeView> with TickerProviderStateMixin {
  final _bible = BibleDataService();
  final _settings = SettingsService();
  final _tts = TtsService();

  late AnimationController _fadeController;
  Timer? _autoTimer;
  Timer? _sleepTimer;

  int _currentPage = 0;
  int _remainingSeconds = 0;
  bool _autoPlay = false;
  bool _ttsEnabled = false;
  int _selectedMinutes = 30;
  bool _showControls = true;

  // 수면용 평안 말씀 목록 (시편 위주)
  final _sleepVerseRefs = const [
    [19, 4, 8], [19, 23, 1], [19, 23, 2], [19, 23, 3], [19, 23, 4],
    [19, 27, 1], [19, 46, 1], [19, 46, 10], [19, 55, 22], [19, 91, 1],
    [19, 91, 2], [19, 91, 4], [19, 91, 11], [19, 116, 7], [19, 119, 105],
    [19, 121, 1], [19, 121, 2], [19, 121, 3], [19, 121, 7], [19, 121, 8],
    [19, 127, 2], [19, 139, 17], [19, 139, 18], [40, 11, 28], [40, 11, 29],
    [43, 14, 27], [50, 4, 6], [50, 4, 7], [23, 26, 3], [23, 40, 31],
  ];

  List<BibleVerse> _verses = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800), value: 1.0);
    _selectedMinutes = _settings.sleepTimerMinutes;
    _showControls = false;  // 시작 시 컨트롤 숨김 (전체화면)
    _loadVerses();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _sleepTimer?.cancel();
    _tts.stop();
    _fadeController.dispose();
    // 시스템 UI 복원 (독립 실행된 경우를 위해)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// 페이드 아웃 → 인덱스 변경 → 페이드 인 (화면 전환 없이 부드럽게)
  void _goToVerse(int index) {
    if (index < 0 || index >= _verses.length || index == _currentPage) return;
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentPage = index);
      _fadeController.forward();
      if (_ttsEnabled) _tts.speak(_verses[index].krv);
    });
  }

  void _loadVerses() {
    final list = <BibleVerse>[];
    for (final ref in _sleepVerseRefs) {
      final v = _bible.getVerse(ref[0], ref[1], ref[2]);
      if (v != null) list.add(v);
    }
    setState(() => _verses = list);
  }

  void _startTimer() {
    _sleepTimer?.cancel();
    _remainingSeconds = _selectedMinutes * 60;
    setState(() {});
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _tts.stop();
        _autoTimer?.cancel();
        if (mounted) {
          if (widget.onClose != null) { widget.onClose!(); } else { Navigator.pop(context); }
        }
        return;
      }
      // UI 갱신은 컨트롤이 보일 때만 (성능 최적화)
      if (_showControls && mounted) setState(() {});
    });
  }

  void _toggleAutoPlay() {
    setState(() => _autoPlay = !_autoPlay);
    if (_autoPlay) {
      _startTimer();
      _autoTimer = Timer.periodic(const Duration(seconds: 8), (_) {
        final next = (_currentPage + 1) % _verses.length;
        _goToVerse(next);
      });
    } else {
      _autoTimer?.cancel();
      _sleepTimer?.cancel();
      _tts.stop();
      setState(() => _remainingSeconds = 0);
    }
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
          widget.onToggleFullscreen?.call();
        },
        child: Stack(
          children: [
            // 배경 그라디언트
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3), radius: 1.2,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0D0D12)],
                ),
              ),
            ),

            // 별 장식 (RepaintBoundary로 감싸 불필요한 재렌더링 방지)
            RepaintBoundary(child: Stack(children: _buildStars())),

            // 말씀 카드 (단일 화면, 페이드 전환)
            if (_verses.isNotEmpty)
              FadeTransition(
                opacity: _fadeController,
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // 달 아이콘
                    Icon(Icons.nightlight_round, size: 28, color: Colors.white.withValues(alpha: 0.15)),
                    const SizedBox(height: 32),
                    // 말씀 본문
                    Text(
                      '"${_verses[_currentPage].krv}"',
                      style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.85),
                        height: 2.0, letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // 참조
                    Text(
                      _verses[_currentPage].refKo,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 2, fontWeight: FontWeight.w500),
                    ),
                  ]),
                )),
              ),

            // 상단 컨트롤 (탭하면 토글)
            if (_showControls) ...[
              // 닫기 + 타이머
              Positioned(
                top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 44, height: 44, alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 22, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                    const Spacer(),
                    if (_remainingSeconds > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                          const SizedBox(width: 6),
                          Text(_formatTime(_remainingSeconds), style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), fontFeatures: const [FontFeature.tabularFigures()])),
                        ]),
                      ),
                  ],
                ),
              ),

              // 하단 컨트롤
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 32, left: 20, right: 20,
                child: Column(children: [
                  // 진행률 점
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                    _verses.length.clamp(0, 15),
                    (i) => Container(
                      width: _currentPage == i ? 16 : 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentPage == i ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  )),
                  const SizedBox(height: 28),

                  // 타이머 선택 + 자동 재생 + TTS
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // 타이머 시간 선택
                    _SleepChip(label: '15분', isActive: _selectedMinutes == 15, onTap: () => setState(() { _selectedMinutes = 15; _settings.setSleepTimerMinutes(15); })),
                    _SleepChip(label: '30분', isActive: _selectedMinutes == 30, onTap: () => setState(() { _selectedMinutes = 30; _settings.setSleepTimerMinutes(30); })),
                    _SleepChip(label: '60분', isActive: _selectedMinutes == 60, onTap: () => setState(() { _selectedMinutes = 60; _settings.setSleepTimerMinutes(60); })),
                  ]),
                  const SizedBox(height: 16),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // TTS 토글
                    GestureDetector(
                      onTap: () => setState(() => _ttsEnabled = !_ttsEnabled),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: _ttsEnabled ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                          const SizedBox(width: 6),
                          Text('음성', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 자동 재생 버튼
                    GestureDetector(
                      onTap: _toggleAutoPlay,
                      child: Container(
                        width: 62, height: 62,
                        decoration: BoxDecoration(
                          color: _autoPlay ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Icon(
                          _autoPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 28, color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    // 랜덤 위치에 별 점 배치 (시드 고정)
    final stars = <Widget>[];
    for (int i = 0; i < 40; i++) {
      final x = ((i * 37 + 13) % 100) / 100.0;
      final y = ((i * 53 + 7) % 100) / 100.0;
      final size = (i % 3 == 0) ? 2.0 : 1.0;
      final opacity = (i % 4 == 0) ? 0.3 : 0.12;
      stars.add(Positioned(
        left: MediaQuery.of(context).size.width * x,
        top: MediaQuery.of(context).size.height * y,
        child: Container(width: size, height: size, decoration: BoxDecoration(color: Colors.white.withValues(alpha: opacity), shape: BoxShape.circle)),
      ));
    }
    return stars;
  }
}

class _SleepChip extends StatelessWidget {
  final String label; final bool isActive; final VoidCallback onTap;
  const _SleepChip({required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: Colors.white.withValues(alpha: 0.2)) : null,
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: isActive ? 0.8 : 0.4), fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
    ));
  }
}
