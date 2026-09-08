import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../domain/sticker_catalog.dart';

class StickerBookScreen extends ConsumerStatefulWidget {
  const StickerBookScreen({super.key});

  @override
  ConsumerState<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends ConsumerState<StickerBookScreen> {
  String _selectedCategory = StickerCatalog.categories.first;

  @override
  Widget build(BuildContext context) {
    final playerProfile = ref.watch(playerProfileProvider);
    final categoryStickers = StickerCatalog.getStickersForCategory(_selectedCategory);
    final totalCollected = playerProfile.unlockedStickers.length;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Pastel Rainbow Album Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFCDD2), // Soft pink
                  Color(0xFFE1BEE7), // Soft purple
                  Color(0xFFBBDEFB), // Soft sky blue
                ],
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      BouncyButton(
                        minWidth: 46,
                        minHeight: 46,
                        padding: const EdgeInsets.all(10),
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
                              'Sticker Book',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Collect all 32 magical stickers!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress Pill
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '$totalCollected / 32',
                              style: const TextStyle(
                                fontSize: 16,
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

                // 8 Category Tabs Bar
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: StickerCatalog.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final cat = StickerCatalog.categories[index];
                      final isSelected = cat == _selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          SoundManager.instance.playPopSound();
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.playfulViolet
                                : Colors.white.withAlpha(210),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Stickers Grid (4 per category)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.90,
                    ),
                    itemCount: categoryStickers.length,
                    itemBuilder: (context, index) {
                      final sticker = categoryStickers[index];
                      final isUnlocked =
                          playerProfile.unlockedStickers.contains(sticker.id);

                      return _buildStickerCard(sticker, isUnlocked, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerCard(StickerData sticker, bool isUnlocked, int index) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          SoundManager.instance.playRewardSound();
        } else {
          SoundManager.instance.playPopSound();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isUnlocked ? AppColors.sunnyGold : Colors.grey.shade300,
            width: isUnlocked ? 3.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? AppColors.sunnyGold.withAlpha(90)
                  : const Color(0x10000000),
              offset: const Offset(0, 6),
              blurRadius: 14,
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              // Sticker Emoji
              Text(
                sticker.emoji,
                style: const TextStyle(fontSize: 56),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .shimmer(duration: 1.seconds),

              const SizedBox(height: 8),

              Text(
                sticker.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.vibrantGreen,
                  letterSpacing: 1.0,
                ),
              ),
            ] else ...[
              // Locked Silhouette
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: Colors.black26,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                sticker.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black38,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                sticker.unlockRequirement,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.coralRed.withAlpha(200),
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .scale(duration: 300.ms, curve: Curves.easeOutBack);
  }
}
