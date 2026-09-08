import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class ColorSortGameScreen extends ConsumerStatefulWidget {
  const ColorSortGameScreen({super.key});

  @override
  ConsumerState<ColorSortGameScreen> createState() => _ColorSortGameScreenState();
}

class _SortColor {
  final String id;
  final String name;
  final Color color;
  final String emoji;

  const _SortColor({
    required this.id,
    required this.name,
    required this.color,
    required this.emoji,
  });
}

class _ColorSortGameScreenState extends ConsumerState<ColorSortGameScreen> {
  final Random _random = Random();

  static const List<_SortColor> _categories = [
    _SortColor(id: 'red', name: 'Red', color: Colors.redAccent, emoji: '🔴'),
    _SortColor(id: 'blue', name: 'Blue', color: Colors.blueAccent, emoji: '🔵'),
    _SortColor(id: 'green', name: 'Green', color: Colors.greenAccent, emoji: '🟢'),
    _SortColor(id: 'yellow', name: 'Yellow', color: Colors.amber, emoji: '🟡'),
  ];

  late _SortColor _currentBalloonColor;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _streak = 0;
    _timeLeft = 30;
    _isPlaying = true;
    _nextBalloon();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _nextBalloon() {
    _currentBalloonColor = _categories[_random.nextInt(_categories.length)];
    setState(() {});
  }

  void _onBinTapped(_SortColor bin) {
    if (!_isPlaying) return;

    if (bin.id == _currentBalloonColor.id) {
      // Correct!
      SoundManager.instance.playPopSound();
      _streak++;
      _score += 10 + (_streak > 3 ? 5 : 0);
      _nextBalloon();
    } else {
      // Wrong bin
      _streak = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again! 🎨'),
          duration: Duration(milliseconds: 400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {});
  }

  void _endGame() {
    _isPlaying = false;
    _gameTimer?.cancel();

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['color_sort'] ?? 0;
    final isNewHigh = _score > previousHigh;

    final coinsEarned = (_score ~/ 6).clamp(10, 50);
    const xpEarned = 35;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'color_sort',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Color Sort',
        emoji: '🎨',
        score: _score,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
        isNewHighScore: isNewHigh,
        onPlayAgain: () {
          Navigator.pop(ctx);
          _startGame();
        },
        onExit: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF80AB), Color(0xFFE91E63)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⭐ Score: $_score',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 5 ? Colors.red.shade800 : Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⏱️ $_timeLeft s',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: _timeLeft <= 5 ? Colors.yellowAccent : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Active Floating Balloon to Sort
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey(_currentBalloonColor.id + _score.toString()),
                  width: 140,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _currentBalloonColor.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _currentBalloonColor.color.withAlpha(140),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.3),
                      radius: 0.8,
                      colors: [
                        Colors.white.withAlpha(220),
                        _currentBalloonColor.color,
                        _currentBalloonColor.color.withAlpha(230),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Tap the matching color bin! 👇',
                style: AppTextStyles.headingMedium.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),

              const Spacer(),

              // Bins at Bottom (4 color boxes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _categories.map((bin) {
                    return GestureDetector(
                      onTap: () => _onBinTapped(bin),
                      child: Container(
                        width: 75,
                        height: 90,
                        decoration: BoxDecoration(
                          color: bin.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(bin.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              bin.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
