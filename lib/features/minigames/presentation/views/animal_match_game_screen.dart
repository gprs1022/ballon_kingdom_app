import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class AnimalMatchGameScreen extends ConsumerStatefulWidget {
  const AnimalMatchGameScreen({super.key});

  @override
  ConsumerState<AnimalMatchGameScreen> createState() => _AnimalMatchGameScreenState();
}

class _AnimalOption {
  final String name;
  final String emoji;
  final String sound;

  const _AnimalOption({
    required this.name,
    required this.emoji,
    required this.sound,
  });
}

class _AnimalMatchGameScreenState extends ConsumerState<AnimalMatchGameScreen> {
  final Random _random = Random();

  static const List<_AnimalOption> _allAnimals = [
    _AnimalOption(name: 'Dog', emoji: '🐶', sound: 'Woof Woof!'),
    _AnimalOption(name: 'Cat', emoji: '🐱', sound: 'Meow Meow!'),
    _AnimalOption(name: 'Lion', emoji: '🦁', sound: 'Roaaar!'),
    _AnimalOption(name: 'Frog', emoji: '🐸', sound: 'Ribbit Ribbit!'),
    _AnimalOption(name: 'Cow', emoji: '🐮', sound: 'Moo Moo!'),
    _AnimalOption(name: 'Duck', emoji: '🦆', sound: 'Quack Quack!'),
    _AnimalOption(name: 'Sheep', emoji: '🐑', sound: 'Baaa Baaa!'),
    _AnimalOption(name: 'Monkey', emoji: '🐵', sound: 'Ooh Ooh Aah!'),
  ];

  late _AnimalOption _targetAnimal;
  late List<_AnimalOption> _roundOptions;
  int _round = 1;
  int _score = 0;
  static const int _maxRounds = 6;

  @override
  void initState() {
    super.initState();
    SoundManager.instance.startBgm();
    _startRound();
  }

  void _startRound() {
    final shuffled = List<_AnimalOption>.from(_allAnimals)..shuffle();
    _roundOptions = shuffled.take(4).toList();
    _targetAnimal = _roundOptions[_random.nextInt(_roundOptions.length)];
    setState(() {});
  }

  void _onAnimalTapped(_AnimalOption selected) {
    if (selected.name == _targetAnimal.name) {
      // Correct!
      SoundManager.instance.playRewardSound();
      _score += 20;

      if (_round >= _maxRounds) {
        _onGameComplete();
      } else {
        _round++;
        _startRound();
      }
    } else {
      SoundManager.instance.playPopSound();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try again! Find the ${_targetAnimal.name}! 🐾'),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onGameComplete() {
    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['animal_match'] ?? 0;
    final isNewHigh = _score > previousHigh;

    const coinsEarned = 25;
    const xpEarned = 35;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'animal_match',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Animal Match',
        emoji: '🦁',
        score: _score,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
        isNewHighScore: isNewHigh,
        onPlayAgain: () {
          Navigator.pop(ctx);
          setState(() {
            _round = 1;
            _score = 0;
          });
          _startRound();
        },
        onExit: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
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
                    Text(
                      'Round $_round / $_maxRounds',
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
                        '⭐ $_score',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Target Prompt Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Find the ${_targetAnimal.name}!',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '🔊 "${_targetAnimal.sound}"',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2x2 Animal Options Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _roundOptions.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final animal = _roundOptions[index];

                      return GestureDetector(
                        onTap: () => _onAnimalTapped(animal),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.amber.shade200, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(animal.emoji, style: const TextStyle(fontSize: 60)),
                              const SizedBox(height: 8),
                              Text(
                                animal.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
