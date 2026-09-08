import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class BalloonRushGameScreen extends ConsumerStatefulWidget {
  const BalloonRushGameScreen({super.key});

  @override
  ConsumerState<BalloonRushGameScreen> createState() => _BalloonRushGameScreenState();
}

class _RushBalloon {
  final int id;
  double x;
  double y;
  final double speed;
  final Color color;
  final double size;

  _RushBalloon({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.size,
  });
}

class _BalloonRushGameScreenState extends ConsumerState<BalloonRushGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _loopTimer;
  bool _isPlaying = false;
  final List<_RushBalloon> _balloons = [];
  int _balloonCounter = 0;

  final List<Color> _colors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.amber,
    Colors.greenAccent,
    Colors.lightBlueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _timeLeft = 30;
    _balloons.clear();
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
    // Spawn balloons
    if (_balloons.length < 10 && _random.nextDouble() < 0.12) {
      _balloons.add(_RushBalloon(
        id: _balloonCounter++,
        x: _random.nextDouble() * 0.8 + 0.1,
        y: 1.1,
        speed: 0.008 + _random.nextDouble() * 0.012,
        color: _colors[_random.nextInt(_colors.length)],
        size: 55 + _random.nextDouble() * 25,
      ));
    }

    setState(() {
      for (final b in _balloons) {
        b.y -= b.speed;
      }
      _balloons.removeWhere((b) => b.y < -0.2);
    });
  }

  void _popBalloon(int id) {
    if (!_isPlaying) return;
    final index = _balloons.indexWhere((b) => b.id == id);
    if (index != -1) {
      SoundManager.instance.playPopSound();
      setState(() {
        _balloons.removeAt(index);
        _score += 10;
      });
    }
  }

  void _endGame() {
    _isPlaying = false;
    _gameTimer?.cancel();
    _loopTimer?.cancel();

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['balloon_rush'] ?? 0;
    final isNewHigh = _score > previousHigh;

    final coinsEarned = (_score ~/ 5).clamp(10, 50);
    const xpEarned = 35;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'balloon_rush',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Balloon Rush',
        emoji: '🎈',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF8A65), Color(0xFFFF5252)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Balloons
              ..._balloons.map((b) {
                final posX = b.x * size.width - (b.size / 2);
                final posY = b.y * size.height - (b.size / 2);
                return Positioned(
                  left: posX,
                  top: posY,
                  child: GestureDetector(
                    onTapDown: (_) => _popBalloon(b.id),
                    child: Container(
                      width: b.size,
                      height: b.size * 1.25,
                      decoration: BoxDecoration(
                        color: b.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withAlpha(120),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.3),
                          radius: 0.8,
                          colors: [
                            Colors.white.withAlpha(200),
                            b.color,
                            b.color.withAlpha(230),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

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
            ],
          ),
        ),
      ),
    );
  }
}
