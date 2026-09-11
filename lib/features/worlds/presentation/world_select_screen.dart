import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../domain/world_config.dart';
import 'level_select_screen.dart';

class WorldSelectScreen extends ConsumerWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.startBgm();
    });

    final playerProfile = ref.watch(playerProfileProvider);
    final worlds = WorldConfig.getAllWorlds();
    final isWide = Responsive.isWideScreen(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Cosmic Adventure Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E88E5), // Deep sky
                  Color(0xFF64B5F6),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
          ),

          // 2. Decorative Clouds
          Positioned(
            top: 40,
            left: 20,
            child: const Icon(Icons.cloud_rounded, size: 90, color: Colors.white60)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 20, duration: 4.seconds),
          ),

          // 3. Content
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 900,
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'World Kingdom',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Explore 6 magical worlds & 120 levels!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Total Stars Pill
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(235),
                            borderRadius: BorderRadius.circular(20),
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
                                '${playerProfile.stars} ⭐️',
                                style: const TextStyle(
                                  fontSize: 15,
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

                  // Worlds List / Grid
                  Expanded(
                    child: isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: worlds.length,
                            itemBuilder: (context, index) => _buildWorldItem(
                              context: context,
                              world: worlds[index],
                              playerProfile: playerProfile,
                              index: index,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: worlds.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _buildWorldItem(
                              context: context,
                              world: worlds[index],
                              playerProfile: playerProfile,
                              index: index,
                            ),
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

  Widget _buildWorldItem({
    required BuildContext context,
    required WorldConfig world,
    required dynamic playerProfile,
    required int index,
  }) {
    final isUnlocked = playerProfile.stars >= world.starRequirement;
    int starsInWorld = 0;
    for (int i = 1; i <= 20; i++) {
      starsInWorld += (playerProfile.levelStars['${world.id}_$i'] as int? ?? 0);
    }
    return _buildWorldCard(
      context: context,
      world: world,
      isUnlocked: isUnlocked,
      playerStars: playerProfile.stars,
      starsInWorld: starsInWorld,
      index: index,
    );
  }

  Widget _buildWorldCard({
    required BuildContext context,
    required WorldConfig world,
    required bool isUnlocked,
    required int playerStars,
    required int starsInWorld,
    required int index,
  }) {
    return BouncyButton(
      minHeight: 110,
      backgroundColor: Colors.white,
      shadowColor: world.themeColors.first.withAlpha(120),
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(16),
      onTap: () {
        if (isUnlocked) {
          SoundManager.instance.playPopSound();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LevelSelectScreen(world: world),
            ),
          );
        } else {
          SoundManager.instance.playPopSound();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Collect ${world.starRequirement - playerStars} more stars to unlock ${world.name}!',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Row(
        children: [
          // World Emoji Banner Container
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: world.themeColors,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: world.themeColors.first.withAlpha(90),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                world.emoji,
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // World Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      world.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isUnlocked)
                      const Icon(Icons.lock_rounded, size: 18, color: Colors.black45),
                  ],
                ),
                const SizedBox(height: 4),
                if (isUnlocked) ...[
                  Text(
                    'Stars: $starsInWorld / 60',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.softAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: starsInWorld / 60.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        world.themeColors.first,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Need ${world.starRequirement} ⭐️ to unlock',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coralRed.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (playerStars / world.starRequirement).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.coralRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Arrow Action
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? world.themeColors.first : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 60).ms)
        .slideX(begin: 0.15, end: 0, duration: 300.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}
