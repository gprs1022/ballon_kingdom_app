import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../shared/widgets/bouncy_button.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../gameplay/domain/models/level_config.dart';
import '../../gameplay/presentation/views/gameplay_screen.dart';
import '../domain/world_config.dart';

class LevelSelectScreen extends ConsumerWidget {
  final WorldConfig? world;

  const LevelSelectScreen({super.key, this.world});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProfile = ref.watch(playerProfileProvider);
    final activeWorld = world ?? WorldConfig.sunnySky();
    final crossAxisCount = Responsive.crossAxisCount(
      context,
      compact: 4,
      mobile: 4,
      tablet: 5,
      desktop: 6,
    );

    // Calculate total stars collected in this specific world
    int worldStarsCollected = 0;
    for (int i = 1; i <= 20; i++) {
      worldStarsCollected += playerProfile.levelStars['${activeWorld.id}_$i'] ?? 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. World-Specific Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: activeWorld.themeColors,
              ),
            ),
          ),

          // 2. Animated floating background decorations
          Positioned(
            top: 40,
            left: 20,
            child: _buildDecorativeIcon(activeWorld.decorativeType)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 20, duration: 4.seconds),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: _buildDecorativeIcon(activeWorld.decorativeType)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: -25, duration: 5.seconds),
          ),

          // 3. Content
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 840,
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      children: [
                        BouncyButton(
                          minWidth: 44,
                          minHeight: 44,
                          padding: const EdgeInsets.all(8),
                          backgroundColor: Colors.white,
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textDark, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      activeWorld.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black38,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(activeWorld.emoji, style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                              const Text(
                                '20 Levels to Explore',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stars Pill
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(235),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x15000000),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.starYellow, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '$worldStarsCollected / 60',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 20 Level Grid
                  Expanded(
                    child: GridView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.84,
                      ),
                      itemCount: activeWorld.levels.length,
                      itemBuilder: (context, index) {
                        final level = activeWorld.levels[index];
                        final isUnlocked = level.index == 1 ||
                            (level.index <= playerProfile.highestUnlockedLevel);
                        final starsEarned =
                            playerProfile.levelStars['${activeWorld.id}_${level.index}'] ?? 0;

                        return _buildLevelTile(
                          context: context,
                          level: level,
                          world: activeWorld,
                          isUnlocked: isUnlocked,
                          starsEarned: starsEarned,
                          animationIndex: index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeIcon(String type) {
    IconData icon;
    switch (type) {
      case 'bubble':
        icon = Icons.bubble_chart_rounded;
        break;
      case 'star':
        icon = Icons.auto_awesome_rounded;
        break;
      case 'leaf':
        icon = Icons.eco_rounded;
        break;
      case 'candy':
        icon = Icons.cake_rounded;
        break;
      case 'snowflake':
        icon = Icons.ac_unit_rounded;
        break;
      default:
        icon = Icons.cloud_rounded;
    }
    return Icon(icon, size: 84, color: Colors.white54);
  }

  Widget _buildLevelTile({
    required BuildContext context,
    required LevelConfig level,
    required WorldConfig world,
    required bool isUnlocked,
    required int starsEarned,
    required int animationIndex,
  }) {
    return BouncyButton(
      minWidth: 0,
      minHeight: 0,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      backgroundColor: isUnlocked ? AppColors.sunnyGold : Colors.white.withAlpha(190),
      shadowColor: isUnlocked
          ? const Color(0xFFC79100)
          : Colors.grey.shade400,
      onTap: () {
        if (!isUnlocked) return;
        SoundManager.instance.playPopSound();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameplayScreen(levelConfig: level, worldConfig: world),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isUnlocked) ...[
            Text(
              '${level.index}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (starIdx) {
                final earned = starIdx < starsEarned;
                return Icon(
                  earned ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: earned ? const Color(0xFFFF8F00) : Colors.black26,
                );
              }),
            ),
          ] else ...[
            const Icon(
              Icons.lock_rounded,
              size: 26,
              color: Colors.black38,
            ),
            const SizedBox(height: 4),
            Text(
              '${level.index}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: (animationIndex * 25).ms)
        .scale(duration: 250.ms, curve: Curves.easeOutBack);
  }
}
