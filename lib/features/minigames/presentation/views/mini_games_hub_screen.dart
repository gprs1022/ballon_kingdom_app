import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/minigame_config.dart';
import 'animal_match_game_screen.dart';
import 'balloon_maze_game_screen.dart';
import 'balloon_rush_game_screen.dart';
import 'bubble_pop_game_screen.dart';
import 'color_sort_game_screen.dart';
import 'fruit_catch_game_screen.dart';
import 'memory_match_game_screen.dart';
import 'shape_puzzle_game_screen.dart';

class MiniGamesHubScreen extends ConsumerWidget {
  const MiniGamesHubScreen({super.key});

  void _launchGame(BuildContext context, String gameId) {
    Widget screen;
    switch (gameId) {
      case 'balloon_rush':
        screen = const BalloonRushGameScreen();
        break;
      case 'bubble_pop':
        screen = const BubblePopGameScreen();
        break;
      case 'fruit_catch':
        screen = const FruitCatchGameScreen();
        break;
      case 'memory_match':
        screen = const MemoryMatchGameScreen();
        break;
      case 'shape_puzzle':
        screen = const ShapePuzzleGameScreen();
        break;
      case 'color_sort':
        screen = const ColorSortGameScreen();
        break;
      case 'balloon_maze':
        screen = const BalloonMazeGameScreen();
        break;
      case 'animal_match':
        screen = const AnimalMatchGameScreen();
        break;
      default:
        screen = const BalloonRushGameScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final crossAxisCount = Responsive.crossAxisCount(
      context,
      compact: 2,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            maxWidth: 880,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mini-Games Hub 🎮',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Play fun games and earn bonus coins & food!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.coins}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 8 Mini-Game Cards Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: MiniGameInfo.allGames.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                  itemBuilder: (context, index) {
                    final game = MiniGameInfo.allGames[index];
                    final highScore = profile.miniGameScores[game.id] ?? 0;

                    return GestureDetector(
                      onTap: () => _launchGame(context, game.id),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: game.gradientColors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: game.gradientColors.first.withAlpha(90),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: 140,
                                  height: 175,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            game.emoji,
                                            style: const TextStyle(fontSize: 34),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(220),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '🪙 +${game.rewardCoins}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        game.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        game.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(220),
                                          fontSize: 11,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(40),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          highScore > 0 ? 'Best: $highScore ⭐' : 'Play Now! 🚀',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
