import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';

class WrongBalloonDialog extends ConsumerStatefulWidget {
  final int score;
  final int poppedCount;
  final int? levelIndex;
  final VoidCallback onRevive;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const WrongBalloonDialog({
    super.key,
    required this.score,
    required this.poppedCount,
    this.levelIndex,
    required this.onRevive,
    required this.onReplay,
    required this.onExit,
  });

  @override
  ConsumerState<WrongBalloonDialog> createState() => _WrongBalloonDialogState();
}

class _WrongBalloonDialogState extends ConsumerState<WrongBalloonDialog> {
  bool _isReviving = false;

  Future<void> _handleRevive() async {
    if (_isReviving) return;
    setState(() => _isReviving = true);

    final adService = ref.read(adServiceProvider);
    final shown = await adService.showRewardedVideo(
      context,
      placement: 'revive_avoid_balloon',
      onReward: () {
        SoundManager.instance.playRewardSound();
        widget.onRevive();
      },
    );

    if (!shown && mounted) {
      setState(() => _isReviving = false);
    }
  }

  void _handleExit() {
    final isPremium = ref.read(playerProfileProvider).isPremiumUnlocked;
    if (!isPremium) {
      ref.read(adServiceProvider).showInterstitialAd(
            context,
            placement: 'game_over_exit',
            onDismissed: widget.onExit,
          );
    } else {
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelText = widget.levelIndex != null ? 'Level ${widget.levelIndex}' : 'Game Over';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              offset: Offset(0, 14),
              blurRadius: 32,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Hazard Badge Icon with soft warning glow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.coralRed, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coralRed.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '⚠️',
                    style: TextStyle(fontSize: 46),
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .shake(duration: 600.ms, curve: Curves.easeInOut),

              const SizedBox(height: 14),

              // 2. Main Title
              const Text(
                'Wrong Balloon! 💥',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coralRed,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 6),

              // 3. Subtitle
              const Text(
                'Oops! You popped the wrong one!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              // 4. Helpful Game Rule Tip Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Avoid balloons have a ⚠️ AVOID badge. Let them float away safely!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5D4037),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5. Stats Summary Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.skyBottom,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Score', '${widget.score} pts', Icons.star_rounded, AppColors.starYellow),
                    _buildStatItem('Popped', '${widget.poppedCount}', Icons.bubble_chart_rounded, AppColors.primaryBlue),
                    _buildStatItem('Stage', levelText, Icons.flag_rounded, AppColors.vibrantGreen),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 6. Second Chance (Watch Ad to Revive)
              BouncyButton(
                minWidth: double.infinity,
                minHeight: 52,
                backgroundColor: const Color(0xFFFF4081),
                onTap: _isReviving ? () {} : _handleRevive,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _isReviving ? 'Loading Revive...' : 'Second Chance! 💖 (Revive)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 7. Try Again Button
              BouncyButton(
                minWidth: double.infinity,
                minHeight: 50,
                backgroundColor: AppColors.sunnyGold,
                onTap: widget.onReplay,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: AppColors.textDark, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Try Again 🔄',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 8. Exit to Home Button
              BouncyButton(
                minWidth: double.infinity,
                minHeight: 46,
                backgroundColor: const Color(0xFFEEEEEE),
                onTap: _handleExit,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded, color: AppColors.textMedium, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Exit 🏠',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMedium,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
