import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../gameplay/presentation/views/gameplay_screen.dart';
import '../../domain/models/learning_item.dart';
import '../../domain/services/learning_content_provider.dart';

class LearningModeHubScreen extends StatelessWidget {
  const LearningModeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWideScreen(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Colorful Pastel Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF81D4FA),
                  Color(0xFFE1BEE7),
                  Color(0xFFFFF9C4),
                ],
              ),
            ),
          ),

          // 2. Animated Clouds
          Positioned(
            top: 40,
            left: 20,
            child: const Icon(Icons.cloud_rounded, size: 90, color: Colors.white60)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 20, duration: 4.seconds),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: const Icon(Icons.cloud_rounded, size: 100, color: Colors.white54)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: -25, duration: 5.seconds),
          ),

          // 3. Main Content
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 840,
              child: Column(
                children: [
                  // Top Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                'Learning Kingdom',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Tap a topic to start popping & learning!',
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Category Selection List / Grid
                  Expanded(
                    child: isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: LearningCategory.values.length,
                            itemBuilder: (context, index) {
                              final category = LearningCategory.values[index];
                              final itemsCount =
                                  LearningContentProvider.getItemsForCategory(category).length;

                              return _buildCategoryCard(
                                context: context,
                                category: category,
                                itemsCount: itemsCount,
                                index: index,
                              );
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: LearningCategory.values.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final category = LearningCategory.values[index];
                              final itemsCount =
                                  LearningContentProvider.getItemsForCategory(category).length;

                              return _buildCategoryCard(
                                context: context,
                                category: category,
                                itemsCount: itemsCount,
                                index: index,
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

  Widget _buildCategoryCard({
    required BuildContext context,
    required LearningCategory category,
    required int itemsCount,
    required int index,
  }) {
    return BouncyButton(
      minHeight: 88,
      backgroundColor: Colors.white,
      shadowColor: category.primaryColor.withAlpha(120),
      borderRadius: BorderRadius.circular(26),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      onTap: () {
        SoundManager.instance.playPopSound();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameplayScreen(learningCategory: category),
          ),
        );
      },
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.primaryColor.withAlpha(35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              category.icon,
              size: 32,
              color: category.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          // Category Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '$itemsCount fun items to discover',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          // Arrow Button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
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
