import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../../rewards/domain/reward_service.dart';

class LevelCompleteDialog extends ConsumerStatefulWidget {
  final LevelCompleteResult result;
  final int score;
  final int targetScore;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const LevelCompleteDialog({
    super.key,
    required this.result,
    required this.score,
    required this.targetScore,
    required this.onNextLevel,
    required this.onReplay,
    required this.onExit,
  });

  @override
  ConsumerState<LevelCompleteDialog> createState() =>
      _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends ConsumerState<LevelCompleteDialog> {
  bool _bonusClaimed = false;

  void _handleNextLevel() {
    final isPremium = ref.read(playerProfileProvider).isPremiumUnlocked;
    if (!isPremium) {
      ref
          .read(adServiceProvider)
          .showInterstitialAd(
            context,
            placement: 'next_level',
            onDismissed: widget.onNextLevel,
          );
    } else {
      widget.onNextLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  const Text(
                    'Level Cleared!',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // 3 Animated Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStar(1, widget.result.starsEarned >= 1, 0.ms),
                      const SizedBox(width: 8),
                      _buildStar(
                        2,
                        widget.result.starsEarned >= 2,
                        200.ms,
                        scale: 1.25,
                      ),
                      const SizedBox(width: 8),
                      _buildStar(3, widget.result.starsEarned >= 3, 400.ms),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Level Up Banner (if triggered)
                  if (widget.result.didLevelUp)
                    Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.playfulViolet,
                                AppColors.candyPink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Level Up! Level ${widget.result.newPlayerLevel} reached!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .shimmer(duration: 1.seconds)
                        .scale(curve: Curves.elasticOut),

                  // Reward Stats Summary Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.skyBottom,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRewardItem(
                          icon: Icons.monetization_on_rounded,
                          iconColor: AppColors.goldAccent,
                          label: '+${widget.result.coinsGranted}',
                          subtext: 'Coins',
                        ),
                        _buildRewardItem(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.softAmber,
                          label: '+${widget.result.xpGranted}',
                          subtext: 'XP',
                        ),
                        _buildRewardItem(
                          icon: Icons.score_rounded,
                          iconColor: AppColors.primaryBlue,
                          label: '${widget.score}',
                          subtext: 'Score',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Rewarded Ad Bonus Button (AdMob)
                  if (!_bonusClaimed)
                    BouncyButton(
                      minWidth: double.infinity,
                      minHeight: 48,
                      backgroundColor: const Color(0xFFE8F0FE),
                      onTap: () async {
                        final adService = ref.read(adServiceProvider);
                        await adService.showRewardedVideo(
                          context,
                          placement: 'level_complete_bonus',
                          onReward: () {
                            ref
                                .read(playerProfileProvider.notifier)
                                .addRewards(coins: 30, xp: 20);
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
                            'Watch Ad: +30 Coins 🎁',
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
                            'Bonus Claimed! +30 Coins 🪙',
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
                  Column(
                    children: [
                      // Next Level Button (triggers Interstitial ad on tap)
                      BouncyButton(
                        minWidth: double.infinity,
                        minHeight: 58,
                        backgroundColor: AppColors.vibrantGreen,
                        onTap: _handleNextLevel,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Next Level',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Replay & Exit Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: BouncyButton(
                              minHeight: 50,
                              backgroundColor: AppColors.sunnyGold,
                              onTap: widget.onReplay,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.textDark,
                                    size: 22,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Replay',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BouncyButton(
                              minHeight: 50,
                              backgroundColor: Colors.grey.shade200,
                              shadowColor: Colors.grey.shade400,
                              onTap: widget.onExit,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_rounded,
                                    color: AppColors.textDark,
                                    size: 22,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Levels',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar(
    int index,
    bool earned,
    Duration delay, {
    double scale = 1.0,
  }) {
    return Transform.scale(
      scale: scale,
      child:
          Icon(
                earned ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 58,
                color: earned ? AppColors.starYellow : Colors.grey.shade300,
              )
              .animate(delay: delay)
              .scale(
                begin: const Offset(0.2, 0.2),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .animate(target: earned ? 1 : 0)
              .shimmer(duration: 800.ms),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtext,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          subtext,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark.withAlpha(150),
          ),
        ),
      ],
    );
  }
}
