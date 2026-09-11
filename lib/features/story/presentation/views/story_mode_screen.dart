import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import '../../domain/kingdom_story_model.dart';

class StoryModeScreen extends ConsumerWidget {
  const StoryModeScreen({super.key});

  void _restoreBeat(BuildContext context, WidgetRef ref, KingdomBeat beat) async {
    final profile = ref.read(playerProfileProvider);

    if (profile.stars < beat.requiredStars) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Collect ${beat.requiredStars} ⭐ stars to unlock this landmark!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (profile.coins < beat.coinCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${beat.coinCost} 🪙 coins to restore this landmark!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(rewardServiceProvider).restoreKingdomBeat(
          beat.id,
          cost: beat.coinCost,
        );

    if (success && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(beat.emoji, style: const TextStyle(fontSize: 70)),
                const SizedBox(height: 12),
                Text(
                  'Landmark Restored! 🎉',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  beat.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  beat.restoredDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Hooray! 🥳', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.startBgm();
    });

    final profile = ref.watch(playerProfileProvider);

    int restoredCount = 0;
    for (final b in KingdomBeat.allBeats) {
      if (profile.restoredKingdomBeats[b.id] == true) {
        restoredCount++;
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9), Color(0xFFB39DDB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Story Mode 🏰',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Restore the Balloon Kingdom landmarks!',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.stars}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          const Text('🪙', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.coins}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Overall Kingdom Restoration Progress Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kingdom Restoration Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '$restoredCount / ${KingdomBeat.allBeats.length} Restored',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: restoredCount / KingdomBeat.allBeats.length,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Landmarks List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: KingdomBeat.allBeats.length,
                  itemBuilder: (context, index) {
                    final beat = KingdomBeat.allBeats[index];
                    final isRestored = profile.restoredKingdomBeats[beat.id] == true;
                    final hasStars = profile.stars >= beat.requiredStars;
                    final canAfford = profile.coins >= beat.coinCost;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Box
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: beat.gradientColors,
                                ),
                              ),
                              child: Center(
                                child: Text(beat.emoji, style: const TextStyle(fontSize: 34)),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          beat.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (isRestored)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            '✨ Restored',
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    beat.worldName,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isRestored ? beat.restoredDescription : beat.ruinDescription,
                                    style: TextStyle(color: Colors.grey[800], fontSize: 12, height: 1.3),
                                  ),
                                  const SizedBox(height: 10),

                                  if (!isRestored)
                                    Row(
                                      children: [
                                        Text(
                                          '⭐ ${beat.requiredStars} Stars',
                                          style: TextStyle(
                                            color: hasStars ? Colors.amber.shade900 : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '🪙 ${beat.coinCost} Coins',
                                          style: TextStyle(
                                            color: canAfford ? Colors.amber.shade900 : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: (hasStars && canAfford)
                                              ? () => _restoreBeat(context, ref, beat)
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          child: const Text(
                                            'Restore 🛠️',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
