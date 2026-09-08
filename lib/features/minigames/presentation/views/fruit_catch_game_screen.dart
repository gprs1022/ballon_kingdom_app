import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class FruitCatchGameScreen extends ConsumerStatefulWidget {
  const FruitCatchGameScreen({super.key});

  @override
  ConsumerState<FruitCatchGameScreen> createState() => _FruitCatchGameScreenState();
}

class _FallingFruit {
  final int id;
  final String emoji;
  double x;
  double y;
  final double speed;

  _FallingFruit({
    required this.id,
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
  });
}

class _FruitCatchGameScreenState extends ConsumerState<FruitCatchGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _loopTimer;
  bool _isPlaying = false;
  final List<_FallingFruit> _fruits = [];
  int _fruitCounter = 0;
  double _basketX = 0.5; // 0.0 to 1.0

  final List<String> _fruitEmojis = ['🍎', '🍌', '🍊', '🍓', '🍇', '🍉', '🍍', '🍒'];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _timeLeft = 30;
    _fruits.clear();
    _isPlaying = true;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        _endGame();
      }
    });

    _loopTimer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!mounted || !_isPlaying) return;
      _tick();
    });
  }

  void _tick() {
    if (_fruits.length < 7 && _random.nextDouble() < 0.12) {
      _fruits.add(_FallingFruit(
        id: _fruitCounter++,
        emoji: _fruitEmojis[_random.nextInt(_fruitEmojis.length)],
        x: _random.nextDouble() * 0.8 + 0.1,
        y: -0.1,
        speed: 0.010 + _random.nextDouble() * 0.010,
      ));
    }

    setState(() {
      for (final f in _fruits) {
        f.y += f.speed;

        // Basket collision check at bottom (y around 0.85)
        if (f.y >= 0.80 && f.y <= 0.90) {
          if ((f.x - _basketX).abs() < 0.15) {
            // Caught!
            SoundManager.instance.playRewardSound();
            _score += 15;
            f.y = 2.0; // Mark for removal
          }
        }
      }
      _fruits.removeWhere((f) => f.y > 1.1);
    });
  }

  void _endGame() {
    _isPlaying = false;
    _gameTimer?.cancel();
    _loopTimer?.cancel();

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['fruit_catch'] ?? 0;
    final isNewHigh = _score > previousHigh;

    final coinsEarned = (_score ~/ 6).clamp(10, 50);
    const xpEarned = 35;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'fruit_catch',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Fruit Catch',
        emoji: '🍎',
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
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _basketX = (details.globalPosition.dx / size.width).clamp(0.1, 0.9);
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFA8E063), Color(0xFF56AB2F)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Falling fruits
                ..._fruits.map((f) {
                  return Positioned(
                    left: f.x * size.width - 24,
                    top: f.y * size.height - 24,
                    child: Text(
                      f.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  );
                }),

                // Basket at bottom
                Positioned(
                  left: _basketX * size.width - 45,
                  bottom: 60,
                  child: Container(
                    width: 90,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D6E63),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      border: Border.all(color: const Color(0xFF5D4037), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧺', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                ),

                // Touch hint bar
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '👈 Slide finger to move basket 👉',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // HUD Header
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
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
                          '🍎 Caught: $_score',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
