import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/learning_item.dart';

class LearningPopOverlay extends StatelessWidget {
  final LearningItem item;
  final VoidCallback onDismiss;

  const LearningPopOverlay({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(245),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: item.color.withAlpha(180), width: 4),
          boxShadow: [
            BoxShadow(
              color: item.color.withAlpha(90),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Display Symbol / Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: item.color.withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.displaySymbol,
                  style: TextStyle(
                    fontSize: item.displaySymbol.length > 2 ? 38 : 56,
                    fontWeight: FontWeight.w900,
                    color: item.color,
                  ),
                ),
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .shimmer(duration: 800.ms),

            const SizedBox(height: 14),

            // Large Word Label
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ).animate().fadeIn(duration: 250.ms),

            const SizedBox(height: 6),

            // Spoken Sentence Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: item.color.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item.spokenText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
            ),
          ],
        ),
      )
          .animate(onComplete: (controller) => onDismiss())
          .scale(
            begin: const Offset(0.4, 0.4),
            end: const Offset(1.0, 1.0),
            duration: 350.ms,
            curve: Curves.elasticOut,
          )
          .then(delay: 1000.ms)
          .fadeOut(duration: 300.ms),
    );
  }
}
