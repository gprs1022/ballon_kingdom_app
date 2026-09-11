import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import 'mini_game_result_dialog.dart';

class ShapePuzzleGameScreen extends ConsumerStatefulWidget {
  const ShapePuzzleGameScreen({super.key});

  @override
  ConsumerState<ShapePuzzleGameScreen> createState() => _ShapePuzzleGameScreenState();
}

class _ShapeItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  bool isPlaced = false;

  _ShapeItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _ShapePuzzleGameScreenState extends ConsumerState<ShapePuzzleGameScreen> {
  late List<_ShapeItem> _shapes;
  String? _selectedShapeId;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    SoundManager.instance.startBgm();
    _initPuzzle();
  }

  void _initPuzzle() {
    _shapes = [
      _ShapeItem(id: 'star', name: 'Star', icon: Icons.star_rounded, color: Colors.amber),
      _ShapeItem(id: 'circle', name: 'Circle', icon: Icons.circle, color: Colors.redAccent),
      _ShapeItem(id: 'square', name: 'Square', icon: Icons.square_rounded, color: Colors.blueAccent),
      _ShapeItem(id: 'triangle', name: 'Triangle', icon: Icons.change_history_rounded, color: Colors.green),
      _ShapeItem(id: 'favorite', name: 'Heart', icon: Icons.favorite_rounded, color: Colors.pinkAccent),
      _ShapeItem(id: 'diamond', name: 'Diamond', icon: Icons.diamond_rounded, color: Colors.purpleAccent),
    ];
    _selectedShapeId = null;
    _score = 0;
    setState(() {});
  }

  void _onSlotTapped(_ShapeItem targetShape) {
    if (targetShape.isPlaced) return;

    if (_selectedShapeId == targetShape.id) {
      // Matched!
      SoundManager.instance.playRewardSound();
      setState(() {
        targetShape.isPlaced = true;
        _selectedShapeId = null;
        _score += 20;
      });

      if (_shapes.every((s) => s.isPlaced)) {
        _onPuzzleComplete();
      }
    } else if (_selectedShapeId != null) {
      // Mismatch gentle tap feedback
      SoundManager.instance.playPopSound();
      setState(() {
        _selectedShapeId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops, try another shape! 🧩'),
          duration: Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onPuzzleComplete() {
    final profile = ref.read(playerProfileProvider);
    final previousHigh = profile.miniGameScores['shape_puzzle'] ?? 0;
    final isNewHigh = _score > previousHigh;

    const coinsEarned = 25;
    const xpEarned = 40;

    ref.read(rewardServiceProvider).recordMiniGameScore(
          'shape_puzzle',
          _score,
          coinsEarned: coinsEarned,
          xpEarned: xpEarned,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MiniGameResultDialog(
        title: 'Shape Puzzle',
        emoji: '⭐',
        score: _score,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
        isNewHighScore: isNewHigh,
        onPlayAgain: () {
          Navigator.pop(ctx);
          _initPuzzle();
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
    final unplacedShapes = _shapes.where((s) => !s.isPlaced).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
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
                      'Match the Shapes! 🧩',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Target Silhouettes Grid (2 rows x 3 cols)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shapes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final shape = _shapes[index];

                      return GestureDetector(
                        onTap: () => _onSlotTapped(shape),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: shape.isPlaced
                                ? shape.color.withAlpha(220)
                                : Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: shape.isPlaced
                                  ? Colors.white
                                  : Colors.white.withAlpha(120),
                              width: 3,
                              style: shape.isPlaced ? BorderStyle.solid : BorderStyle.none,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              shape.icon,
                              size: 54,
                              color: shape.isPlaced
                                  ? Colors.white
                                  : Colors.white.withAlpha(60),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Shape Selection Tray at bottom
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedShapeId == null
                            ? '1. Tap a shape below, then tap its slot!'
                            : '2. Now tap the matching slot above! 👆',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: unplacedShapes.isEmpty
                            ? const Center(child: Text('🎉 All matched!'))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: unplacedShapes.map((shape) {
                                  final isSelected = _selectedShapeId == shape.id;
                                  return GestureDetector(
                                    onTap: () {
                                      SoundManager.instance.playPopSound();
                                      setState(() {
                                        _selectedShapeId = shape.id;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? shape.color
                                            : shape.color.withAlpha(50),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : shape.color,
                                          width: isSelected ? 4 : 2,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: shape.color.withAlpha(120),
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        shape.icon,
                                        size: 40,
                                        color: isSelected
                                            ? Colors.white
                                            : shape.color,
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
            ],
          ),
        ),
      ),
    );
  }
}
