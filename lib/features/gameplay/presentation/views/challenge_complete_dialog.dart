import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../domain/models/challenge_mission.dart';

class ChallengeCompleteDialog extends ConsumerStatefulWidget {
  final bool isVictory;
  final MedalType medal;
  final int timeRemaining;
  final int score;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const ChallengeCompleteDialog({
    super.key,
    required this.isVictory,
    required this.medal,
    required this.timeRemaining,
    required this.score,
    required this.onReplay,
    required this.onExit,
  });

  @override
  ConsumerState<ChallengeCompleteDialog> createState() =>
      _ChallengeCompleteDialogState();
}

class _ChallengeCompleteDialogState
    extends ConsumerState<ChallengeCompleteDialog> {
  bool _bonusClaimed = false;

  void _handleExit() {
    final isPremium = ref.read(playerProfileProvider).isPremiumUnlocked;
    if (!isPremium) {
      ref
          .read(adServiceProvider)
          .showInterstitialAd(
            context,
            placement: 'challenge_exit',
            onDismissed: widget.onExit,
          );
    } else {
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38000000),
              offset: Offset(0, 12),
              blurRadius: 28,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Header
              Text(
                widget.isVictory ? 'Mission Cleared!' : 'Good Effort!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: widget.isVictory
                      ? AppColors.textDark
                      : AppColors.coralRed,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 16),

              if (widget.isVictory) ...[
                // Big Medal Graphic
                Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: widget.medal.color.withAlpha(40),
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.medal.color, width: 4),
                      ),
                      child: Center(
                        child: Icon(
                          widget.medal.icon,
                          size: 54,
                          color: widget.medal.color,
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut)
                    .shimmer(duration: 900.ms),

                const SizedBox(height: 10),

                Text(
                  widget.medal.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: widget.medal.color,
                  ),
                ),

                const SizedBox(height: 16),

                // Stats summary
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.skyBottom,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Score',
                        '${widget.score} pts',
                        Icons.star_rounded,
                        AppColors.starYellow,
                      ),
                      _buildStatItem(
                        'Time Left',
                        '${widget.timeRemaining}s',
                        Icons.timer_rounded,
                        AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 70,
                  color: AppColors.coralRed,
                ).animate().shake(duration: 500.ms),
                const SizedBox(height: 12),
                const Text(
                  'Almost had it!\nTap Replay to try again!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // AdMob Rewarded Bonus Button
              if (!_bonusClaimed)
                BouncyButton(
                  minWidth: double.infinity,
                  minHeight: 48,
                  backgroundColor: const Color(0xFFE8F0FE),
                  onTap: () async {
                    final adService = ref.read(adServiceProvider);
                    await adService.showRewardedVideo(
                      context,
                      placement: 'challenge_complete_bonus',
                      onReward: () {
                        ref
                            .read(playerProfileProvider.notifier)
                            .addRewards(coins: 50, xp: 30);
                        SoundManager.instance.playRewardSound();
                        if (mounted) {
                          setState(() {
                            _bonusClaimed = true;
                          });
                        }
                      },
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_collection_rounded,
                        color: Color(0xFF1967D2),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Watch Ad: +50 Coins 🎁',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1967D2),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Bonus Claimed! +50 Coins 🪙',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Action Buttons
              BouncyButton(
                minWidth: double.infinity,
                minHeight: 54,
                backgroundColor: widget.isVictory
                    ? AppColors.vibrantGreen
                    : AppColors.sunnyGold,
                onTap: widget.onReplay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: widget.isVictory
                          ? Colors.white
                          : AppColors.textDark,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isVictory ? 'Play Again' : 'Try Again',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: widget.isVictory
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              BouncyButton(
                minWidth: double.infinity,
                minHeight: 48,
                backgroundColor: Colors.grey.shade200,
                shadowColor: Colors.grey.shade400,
                onTap: _handleExit,
                child: const Text(
                  'Missions Hub',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDark.withAlpha(150),
                fontWeight: FontWeight.w600,
              ),
            ),
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
      ],
    );
  }
}
