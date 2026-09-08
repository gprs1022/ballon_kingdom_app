import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class MemoryMatchGameScreen extends ConsumerStatefulWidget {
  const MemoryMatchGameScreen({super.key});

  @override
  ConsumerState<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryCard {
  final int id;
  final String content;
  bool isFaceUp = false;
  bool isMatched = false;

  _MemoryCard({
    required this.id,
    required this.content,
  });
}

class _MemoryMatchGameScreenState extends ConsumerState<MemoryMatchGameScreen> {
  final List<String> _emojis = ['🐶', '🐱', '🐼', '🦁', '🐰', '🦄'];
  List<_MemoryCard> _cards = [];
  int _moves = 0;
  int _pairsFound = 0;
  _MemoryCard? _firstSelected;
  _MemoryCard? _secondSelected;
  bool _isBusy = false;
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _moves = 0;
    _pairsFound = 0;
    _firstSelected = null;
    _secondSelected = null;
    _isBusy = false;
    _secondsElapsed = 0;

    final cardContents = [..._emojis, ..._emojis]..shuffle();
    _cards = List.generate(
      cardContents.length,
      (i) => _MemoryCard(id: i, content: cardContents[i]),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
    setState(() {});
  }

  void _onCardTapped(_MemoryCard card) {
    if (_isBusy || card.isFaceUp || card.isMatched) return;

    SoundManager.instance.playPopSound();
    setState(() {
      card.isFaceUp = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _secondSelected = card;
      _moves++;
      _isBusy = true;

      if (_firstSelected!.content == _secondSelected!.content) {
        // Matched!
        SoundManager.instance.playRewardSound();
        _firstSelected!.isMatched = true;
        _secondSelected!.isMatched = true;
        _pairsFound++;
        _firstSelected = null;
        _secondSelected = null;
        _isBusy = false;

        if (_pairsFound == _emojis.length) {
          _onGameComplete();
        }
      } else {
        // Not a match
        Timer(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _firstSelected?.isFaceUp = false;
            _secondSelected?.isFaceUp = false;
            _firstSelected = null;
            _secondSelected = null;
            _isBusy = false;
          });
        });
      }
    }
  }

  void _onGameComplete() {
    _timer?.cancel();
    final score = (1000 - (_moves * 30) - (_secondsElapsed * 10)).clamp(100, 999);

    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['memory_match'] ?? 0;
    final isNewHigh = score > previousHigh;

    const coinsEarned = 30;
    const xpEarned = 45;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'memory_match',
          score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Memory Match',
        emoji: '🃏',
        score: score,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
        isNewHighScore: isNewHigh,
        onPlayAgain: () {
          Navigator.pop(ctx);
          _startNewGame();
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
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
                        'Pairs: $_pairsFound / ${_emojis.length}',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⏱️ $_secondsElapsed s',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Cards Grid (4 columns x 3 rows)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cards.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final isShown = card.isFaceUp || card.isMatched;

                      return GestureDetector(
                        onTap: () => _onCardTapped(card),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isShown ? Colors.white : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: card.isMatched
                                  ? Colors.green
                                  : (isShown ? Colors.amber.shade400 : Colors.white),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isShown ? card.content : '❓',
                              style: TextStyle(
                                fontSize: isShown ? 42 : 32,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
