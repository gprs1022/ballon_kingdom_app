import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../domain/pet.dart';
import 'egg_hatch_dialog.dart';

class PetsSanctuaryScreen extends ConsumerStatefulWidget {
  const PetsSanctuaryScreen({super.key});

  @override
  ConsumerState<PetsSanctuaryScreen> createState() => _PetsSanctuaryScreenState();
}

class _PetsSanctuaryScreenState extends ConsumerState<PetsSanctuaryScreen> {
  bool _isFeeding = false;

  void _feedActivePet(Pet pet) async {
    final rewardService = ref.read(rewardServiceProvider);
    final success = await rewardService.feedPet(pet.id);

    if (success) {
      setState(() => _isFeeding = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() => _isFeeding = false);
        }
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough pet food! Pop balloons or clear levels to earn food!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _hatchNewEgg() async {
    final rewardService = ref.read(rewardServiceProvider);
    final newPet = await rewardService.hatchEgg();

    if (newPet != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => EggHatchDialog(
          hatchedPet: newPet,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    } else if (mounted) {
      final profile = ref.read(playerProfileProvider);
      final msg = profile.coins < 40
          ? 'You need 40 coins to hatch an egg!'
          : 'You already unlocked all 8 magical pets!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProfile = ref.watch(playerProfileProvider);
    final activePet = playerProfile.activePet ??
        const Pet(
          id: 'pet_puppy',
          species: 'Puppy',
          name: 'Barnaby',
          emoji: '🐶',
          primaryColor: Color(0xFF8D6E63),
          accentColor: Color(0xFFFFD54F),
        );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Meadow & Garden Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF81D4FA), // Sky blue
                  Color(0xFFC8E6C9), // Gentle green meadow
                  Color(0xFFA5D6A7),
                ],
              ),
            ),
          ),

          // 2. Animated floating background clouds
          Positioned(
            top: 40,
            left: 20,
            child: const Icon(Icons.cloud_rounded, size: 90, color: Colors.white60)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 20, duration: 4.seconds),
          ),

          // 3. Content
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
                              'Pet Sanctuary',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Care for your cute companions!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pet Food Pill
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🦴', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '${playerProfile.petFood}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Coins Pill
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                color: AppColors.goldAccent, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${playerProfile.coins}',
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

                const Spacer(flex: 1),

                // Active Pet Showcase Stage
                Column(
                  children: [
                    // Emote Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        _isFeeding ? 'Yummy! Thank you! 🥰' : 'Let\'s pop some balloons! 🎈',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ).animate(target: _isFeeding ? 1 : 0).scale(duration: 200.ms),

                    const SizedBox(height: 14),

                    // Pet Avatar
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activePet.primaryColor,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activePet.primaryColor.withAlpha(90),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          activePet.emoji,
                          style: const TextStyle(fontSize: 82),
                        ),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.06, 1.06),
                          duration: 1.4.seconds,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 16),

                    // Name and Level Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activePet.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: activePet.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Lvl ${activePet.level}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Pet XP Progress Bar
                    Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: activePet.xpProgress,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                activePet.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${activePet.xp} / ${activePet.xpForNextLevel} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Feed & Hatch Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      // Feed Pet Button
                      Expanded(
                        child: BouncyButton(
                          minHeight: 56,
                          backgroundColor: AppColors.vibrantGreen,
                          onTap: () => _feedActivePet(activePet),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🦴', style: TextStyle(fontSize: 22)),
                              SizedBox(width: 8),
                              Text(
                                'Feed Pet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Hatch Mystery Egg Button
                      Expanded(
                        child: BouncyButton(
                          minHeight: 56,
                          backgroundColor: AppColors.sunnyGold,
                          onTap: _hatchNewEgg,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🥚', style: TextStyle(fontSize: 22)),
                              SizedBox(width: 8),
                              Text(
                                'Hatch (40 🪙)',
                                style: TextStyle(
                                  fontSize: 18,
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
                ),

                const SizedBox(height: 20),

                // Pet Companions Selector Carousel
                Container(
                  height: 94,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: playerProfile.pets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final pet = playerProfile.pets[index];
                      final isSelected = pet.id == activePet.id;

                      return GestureDetector(
                        onTap: () {
                          SoundManager.instance.playPopSound();
                          ref.read(rewardServiceProvider).setActivePet(pet.id);
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? pet.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x15000000),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(pet.emoji, style: const TextStyle(fontSize: 34)),
                              const SizedBox(height: 4),
                              Text(
                                pet.species,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? pet.primaryColor : Colors.black87,
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
        ],
      ),
    );
  }
}
