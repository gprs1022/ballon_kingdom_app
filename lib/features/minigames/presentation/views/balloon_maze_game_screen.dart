import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class BalloonMazeGameScreen extends ConsumerStatefulWidget {
  const BalloonMazeGameScreen({super.key});

  @override
  ConsumerState<BalloonMazeGameScreen> createState() => _BalloonMazeGameScreenState();
}

class _BalloonMazeGameScreenState extends ConsumerState<BalloonMazeGameScreen> {
  double _balloonX = 0.5;
  double _balloonY = 0.85;
  int _score = 0;
  int _secondsElapsed = 0;
  Timer? _timer;

  // Obstacle gates
  final List<Rect> _obstacles = [
    const Rect.fromLTWH(0.0, 0.60, 0.40, 0.04),
    const Rect.fromLTWH(0.60, 0.60, 0.40, 0.04),
    const Rect.fromLTWH(0.25, 0.35, 0.50, 0.04),
  ];

  @override
  void initState() {
    super.initState();
    _startMaze();
  }

  void _startMaze() {
    _balloonX = 0.5;
    _balloonY = 0.85;
    _secondsElapsed = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      final newX = (_balloonX + details.delta.dx / size.width).clamp(0.08, 0.92);
      final newY = (_balloonY + details.delta.dy / size.height).clamp(0.08, 0.90);

      // Check collision with obstacles
      bool collides = false;
      for (final obs in _obstacles) {
        if (obs.contains(Offset(newX, newY))) {
          collides = true;
          break;
        }
      }

      if (!collides) {
        _balloonX = newX;
        _balloonY = newY;

        // Check if reached star goal at top (y <= 0.12)
        if (_balloonY <= 0.14) {
          _onGoalReached();
        }
      } else {
        // Gentle bounce off breeze
        SoundManager.instance.playPopSound();
      }
    });
  }

  void _onGoalReached() {
    SoundManager.instance.playRewardSound();
    _timer?.cancel();
    _score = (1000 - (_secondsElapsed * 20)).clamp(100, 999);

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['balloon_maze'] ?? 0;
    final isNewHigh = _score > previousHigh;

    const coinsEarned = 30;
    const xpEarned = 45;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'balloon_maze',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Balloon Maze',
        emoji: '🌀',
        score: _score,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
        isNewHighScore: isNewHigh,
        onPlayAgain: () {
          Navigator.pop(ctx);
          _startMaze();
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
    _timer?.cancel();
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
            colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
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
                    Text(
                      'Guide to the Star! 🌟',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '⏱️ $_secondsElapsed s',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Star Goal at Top
              const Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 48)),
                      Text('GOAL', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),

              // Breeze Obstacles
              ..._obstacles.map((obs) {
                return Positioned(
                  left: obs.left * size.width,
                  top: obs.top * size.height,
                  width: obs.width * size.width,
                  height: obs.height * size.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(160),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withAlpha(80),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('💨 Breeze 💨', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              }),

              // Player Floating Balloon
              Positioned(
                left: _balloonX * size.width - 28,
                top: _balloonY * size.height - 35,
                child: GestureDetector(
                  onPanUpdate: (d) => _onPanUpdate(d, size),
                  child: Container(
                    width: 56,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(100),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        radius: 0.8,
                        colors: [
                          Colors.white.withAlpha(200),
                          Colors.redAccent,
                          Colors.red.shade700,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text('🎈', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
              ),

              // Bottom Drag Hint
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '👆 Drag the balloon to steer it!',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
