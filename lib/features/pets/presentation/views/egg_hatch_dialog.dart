import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../domain/pet.dart';

class EggHatchDialog extends StatefulWidget {
  final Pet hatchedPet;
  final VoidCallback onDismiss;

  const EggHatchDialog({
    super.key,
    required this.hatchedPet,
    required this.onDismiss,
  });

  @override
  State<EggHatchDialog> createState() => _EggHatchDialogState();
}

class _EggHatchDialogState extends State<EggHatchDialog> {
  int _tapCount = 0;
  bool _isHatched = false;

  void _onEggTapped() {
    if (_isHatched) return;
    SoundManager.instance.playPopSound();

    setState(() {
      _tapCount++;
      if (_tapCount >= 3) {
        _isHatched = true;
        SoundManager.instance.playRewardSound();
      }
    });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHatched ? 'A New Pet Hatched!' : 'Tap the Mystery Egg!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isHatched
                  ? 'Say hello to your new companion!'
                  : 'Tap 3 times to crack the shell!',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            if (!_isHatched) ...[
              // Mystery Egg Graphic (Interactive Tappable)
              GestureDetector(
                onTap: _onEggTapped,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing background
                    Container(
                      width: 140,
                      height: 170,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF9C4),
                            Color(0xFFFFD54F),
                            Color(0xFFFFB300),
                          ],
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(140, 170),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldAccent.withAlpha(120),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _tapCount == 0
                              ? Icons.star_rounded
                              : (_tapCount == 1 ? Icons.broken_image_rounded : Icons.flash_on_rounded),
                          size: 48,
                          color: Colors.white.withAlpha(190),
                        ),
                      ),
                    )
                        .animate(
                          target: _tapCount.toDouble(),
                        )
                        .shake(duration: 350.ms, curve: Curves.easeInOut),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Taps: $_tapCount / 3',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.softAmber,
                ),
              ),
            ] else ...[
              // Hatched Pet Celebration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.hatchedPet.primaryColor.withAlpha(40),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.hatchedPet.primaryColor,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.hatchedPet.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .shimmer(duration: 900.ms),

              const SizedBox(height: 14),

              Text(
                widget.hatchedPet.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Species: ${widget.hatchedPet.species}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.hatchedPet.primaryColor,
                ),
              ),
            ],

            const SizedBox(height: 24),

            if (_isHatched)
              BouncyButton(
                minWidth: double.infinity,
                minHeight: 54,
                backgroundColor: AppColors.vibrantGreen,
                onTap: widget.onDismiss,
                child: const Text(
                  'Welcome Pet!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
