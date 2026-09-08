import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class BubblePopGameScreen extends ConsumerStatefulWidget {
  const BubblePopGameScreen({super.key});

  @override
  ConsumerState<BubblePopGameScreen> createState() => _BubblePopGameScreenState();
}

class _SoapBubble {
  final int id;
  double x;
  double y;
  final double speed;
  final double size;
  final double wobbleFreq;

  _SoapBubble({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.wobbleFreq,
  });
}

class _BubblePopGameScreenState extends ConsumerState<BubblePopGameScreen> {
  final Random _random = Random();
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _loopTimer;
  bool _isPlaying = false;
  final List<_SoapBubble> _bubbles = [];
  int _bubbleCounter = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _timeLeft = 30;
    _bubbles.clear();
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
    if (_bubbles.length < 12 && _random.nextDouble() < 0.15) {
      _bubbles.add(_SoapBubble(
        id: _bubbleCounter++,
        x: _random.nextDouble() * 0.8 + 0.1,
        y: 1.1,
        speed: 0.006 + _random.nextDouble() * 0.008,
        size: 50 + _random.nextDouble() * 35,
        wobbleFreq: _random.nextDouble() * 4,
      ));
    }

    setState(() {
      for (final b in _bubbles) {
        b.y -= b.speed;
        b.x += sin(b.y * 10 + b.wobbleFreq) * 0.002;
      }
      _bubbles.removeWhere((b) => b.y < -0.2);
    });
  }

  void _popBubble(int id) {
    if (!_isPlaying) return;
    final index = _bubbles.indexWhere((b) => b.id == id);
    if (index != -1) {
      SoundManager.instance.playPopSound();
      setState(() {
        _bubbles.removeAt(index);
        _score += 10;
      });
    }
  }

  void _endGame() {
    _isPlaying = false;
    _gameTimer?.cancel();
    _loopTimer?.cancel();

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['bubble_pop'] ?? 0;
    final isNewHigh = _score > previousHigh;

    final coinsEarned = (_score ~/ 6).clamp(10, 45);
    const xpEarned = 30;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'bubble_pop',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Bubble Pop',
        emoji: '🫧',
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
            colors: [Color(0xFF80DEEA), Color(0xFF00ACC1), Color(0xFF006064)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._bubbles.map((b) {
                final posX = b.x * size.width - (b.size / 2);
                final posY = b.y * size.height - (b.size / 2);
                return Positioned(
                  left: posX,
                  top: posY,
                  child: GestureDetector(
                    onTapDown: (_) => _popBubble(b.id),
                    child: Container(
                      width: b.size,
                      height: b.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                        gradient: RadialGradient(
                          center: const Alignment(-0.35, -0.35),
                          radius: 0.9,
                          colors: [
                            Colors.white.withAlpha(180),
                            Colors.lightBlueAccent.withAlpha(80),
                            Colors.purpleAccent.withAlpha(60),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withAlpha(60),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

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
                        '🫧 Bubbles: $_score',
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
