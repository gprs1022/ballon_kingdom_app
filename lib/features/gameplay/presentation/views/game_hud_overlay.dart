import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../providers/gameplay_notifier.dart';

class GameHudOverlay extends ConsumerWidget {
  final VoidCallback onPauseTap;

  const GameHudOverlay({super.key, required this.onPauseTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayNotifierProvider);
    final playerProfile = ref.watch(playerProfileProvider);

    return SafeArea(
      child: ResponsiveContainer(
        maxWidth: 720,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: math.max(360.0, math.min(720.0, MediaQuery.sizeOf(context).width - 32)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                if (gameState.isChallengeMode) ...[
                  // 1. Lives Display (3 Hearts)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final isAlive = index < gameState.lives;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isAlive ? AppColors.coralRed : Colors.grey.shade400,
                            size: 22,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. Timer Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: gameState.timeRemaining <= 10
                          ? const Color(0xFFFFEBEE)
                          : Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(20),
                      border: gameState.timeRemaining <= 10
                          ? Border.all(color: AppColors.coralRed, width: 2)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: gameState.timeRemaining <= 10
                              ? AppColors.coralRed
                              : AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${gameState.timeRemaining}s',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: gameState.timeRemaining <= 10
                                ? AppColors.coralRed
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (gameState.isLevelMode) ...[
                  _buildStatPill(
                    icon: Icons.flag_rounded,
                    iconColor: AppColors.coralRed,
                    value: 'Level ${gameState.levelConfig!.index}',
                  ),
                ] else ...[
                  _buildStatPill(
                    icon: Icons.bubble_chart_rounded,
                    iconColor: AppColors.coralRed,
                    value: '${gameState.poppedCount}',
                  ),
                ],

                const SizedBox(width: 8),

                // Coins pill
                _buildStatPill(
                  icon: Icons.monetization_on_rounded,
                  iconColor: AppColors.goldAccent,
                  value: '${playerProfile.coins}',
                ),

                const Spacer(),

                // Sound toggle button
                StatefulBuilder(
                  builder: (context, setState) {
                    final isMuted = SoundManager.instance.isMuted;
                    return BouncyButton(
                      minWidth: 44,
                      minHeight: 44,
                      padding: const EdgeInsets.all(9),
                      backgroundColor: Colors.white,
                      onTap: () {
                        SoundManager.instance.toggleMute();
                        setState(() {});
                      },
                      child: Icon(
                        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: isMuted ? Colors.grey : AppColors.textDark,
                        size: 22,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Pause button
                BouncyButton(
                  minWidth: 44,
                  minHeight: 44,
                  padding: const EdgeInsets.all(9),
                  backgroundColor: AppColors.sunnyGold,
                  onTap: onPauseTap,
                  child: const Icon(
                    Icons.pause_rounded,
                    color: AppColors.textDark,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),

            // Target Progress Bar (Level or Challenge Mode)
            if (gameState.isLevelMode || gameState.isChallengeMode) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(225),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      gameState.isChallengeMode ? Icons.task_alt_rounded : Icons.star_rounded,
                      color: gameState.isChallengeMode ? AppColors.vibrantGreen : AppColors.starYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: gameState.progressFraction,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.vibrantGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      gameState.isChallengeMode
                          ? '${gameState.missionProgress}/${gameState.challengeMission!.targetCount}'
                          : '${gameState.score}/${gameState.levelConfig!.targetScore}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
