import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/apk_download_helper.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../gameplay/presentation/views/challenge_hub_screen.dart';
import '../../gameplay/presentation/views/free_play_screen.dart';
import '../../house/presentation/views/balloon_house_screen.dart';
import '../../learning/presentation/views/learning_mode_hub_screen.dart';
import '../../minigames/presentation/views/mini_games_hub_screen.dart';
import '../../parental/presentation/views/parent_dashboard_screen.dart';
import '../../parental/presentation/views/parent_gate_dialog.dart';
import '../../pets/presentation/views/pets_sanctuary_screen.dart';
import '../../rewards/presentation/views/daily_rewards_dialog.dart';
import '../../rewards/presentation/views/sticker_book_screen.dart';
import '../../shop/presentation/views/shop_screen.dart';
import '../../story/presentation/views/story_mode_screen.dart';
import '../../worlds/presentation/world_select_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start ambient joyful BGM if not already playing or muted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.startBgm();
    });

    final playerProfile = ref.watch(playerProfileProvider);
    final xpInCurrentLevel = playerProfile.xp % 100;
    final activePet = playerProfile.activePet;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Sunny Sky Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.skyTop,
                  Color(0xFFBBDEFB),
                  AppColors.skyBottom,
                ],
              ),
            ),
          ),

          // 2. Animated floating background clouds
          Positioned(
            top: 50,
            left: 20,
            child:
                const Icon(
                      Icons.cloud_rounded,
                      size: 100,
                      color: Colors.white70,
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveX(
                      begin: 0,
                      end: 25,
                      duration: 4.seconds,
                      curve: Curves.easeInOut,
                    ),
          ),
          Positioned(
            top: 130,
            right: 25,
            child:
                const Icon(
                      Icons.cloud_rounded,
                      size: 120,
                      color: Colors.white60,
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveX(
                      begin: 0,
                      end: -30,
                      duration: 5.seconds,
                      curve: Curves.easeInOut,
                    ),
          ),

          // 3. Main Content
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 580,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    // Top Row: Stats & Mute Toggle
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 480.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                                      // Coins & Stars Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(235),
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x18000000),
                                              offset: Offset(0, 4),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.monetization_on_rounded,
                                              color: AppColors.goldAccent,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${playerProfile.coins}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.star_rounded,
                                              color: AppColors.starYellow,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${playerProfile.stars}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Right Controls: Daily Rewards, Shop, Mute Toggle
                                      Row(
                                        children: [
                                          // Daily Rewards Button with notification badge
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              BouncyButton(
                                                minWidth: 44,
                                                minHeight: 44,
                                                padding: const EdgeInsets.all(
                                                  9,
                                                ),
                                                backgroundColor: Colors.white,
                                                onTap: () {
                                                  SoundManager.instance
                                                      .playPopSound();
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        const DailyRewardsDialog(),
                                                  );
                                                },
                                                child: const Text(
                                                  '🎁',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              if (playerProfile
                                                  .canClaimDailyReward)
                                                Positioned(
                                                  top: -2,
                                                  right: -2,
                                                  child: Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          const SizedBox(width: 8),

                                          // Shop Button
                                          BouncyButton(
                                            minWidth: 44,
                                            minHeight: 44,
                                            padding: const EdgeInsets.all(9),
                                            backgroundColor: Colors.white,
                                            onTap: () {
                                              SoundManager.instance
                                                  .playPopSound();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const ShopScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              '🛍️',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),

                                          // Watch Ad Reward Button
                                          BouncyButton(
                                            minWidth: 44,
                                            minHeight: 44,
                                            padding: const EdgeInsets.all(9),
                                            backgroundColor: Colors.white,
                                            onTap: () async {
                                              SoundManager.instance
                                                  .playPopSound();
                                              final adService = ref.read(
                                                adServiceProvider,
                                              );
                                              await adService.showRewardedVideo(
                                                context,
                                                placement: 'home_screen_gift',
                                                onReward: () {
                                                  ref
                                                      .read(
                                                        playerProfileProvider
                                                            .notifier,
                                                      )
                                                      .addRewards(coins: 25);
                                                  SoundManager.instance
                                                      .playRewardSound();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        '🎉 Claimed +25 Coins from watching an ad! 🪙',
                                                      ),
                                                      duration: Duration(
                                                        seconds: 2,
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              '🎬',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // Parent Dashboard Button (Guarded with Parent Gate)
                                          BouncyButton(
                                            minWidth: 44,
                                            minHeight: 44,
                                            padding: const EdgeInsets.all(9),
                                            backgroundColor: Colors.white,
                                            onTap: () {
                                              SoundManager.instance
                                                  .playPopSound();
                                              showDialog(
                                                context: context,
                                                builder: (_) => ParentGateDialog(
                                                  onSuccess: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const ParentDashboardScreen(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              '🛡️',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // Sound Mute Toggle
                                          StatefulBuilder(
                                            builder: (context, setState) {
                                              final isMuted =
                                                  SoundManager.instance.isMuted;
                                              return BouncyButton(
                                                minWidth: 44,
                                                minHeight: 44,
                                                padding: const EdgeInsets.all(
                                                  9,
                                                ),
                                                backgroundColor: Colors.white,
                                                onTap: () {
                                                  SoundManager.instance
                                                      .toggleMute();
                                                  setState(() {});
                                                },
                                                child: Icon(
                                                  isMuted
                                                      ? Icons.volume_off_rounded
                                                      : Icons.volume_up_rounded,
                                                  color: isMuted
                                                      ? Colors.grey
                                                      : AppColors.textDark,
                                                  size: 22,
                                                ),
                                              );
                                            },
                                          ),

                                          // Web APK Download Button (Web Only)
                                          if (kIsWeb) ...[
                                            const SizedBox(width: 8),
                                            BouncyButton(
                                              minWidth: 44,
                                              minHeight: 44,
                                              padding: const EdgeInsets.all(9),
                                              backgroundColor: const Color(
                                                0xFF2E7D32,
                                              ),
                                              onTap: () {
                                                SoundManager.instance
                                                    .playRewardSound();
                                                ApkDownloadHelper.downloadReleaseApk();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '📥 Downloading Balloon Kingdom Release APK (${ApkDownloadHelper.fileSize})... 🚀',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                              child: const Icon(
                                                Icons.download_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Player Level & Active Companion Pill
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Level & XP
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(210),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.bolt_rounded,
                                            color: AppColors.softAmber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Lvl ${playerProfile.level}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 65,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: xpInCurrentLevel / 100.0,
                                                minHeight: 6,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.softAmber),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (activePet != null) ...[
                                      const SizedBox(width: 8),
                                      // Active Pet Avatar Tag
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PetsSanctuaryScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(220),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: activePet.primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                activePet.emoji,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                activePet.name,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: activePet.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // 4. Kingdom Title & Mascot Banner
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildDecorativeBalloon(
                                        AppColors.candyPink,
                                        -12,
                                        1.0,
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                            Icons.workspace_premium_rounded,
                                            size: 50,
                                            color: AppColors.sunnyGold,
                                          )
                                          .animate(
                                            onPlay: (c) =>
                                                c.repeat(reverse: true),
                                          )
                                          .scale(
                                            begin: const Offset(1, 1),
                                            end: const Offset(1.12, 1.12),
                                            duration: 1.5.seconds,
                                            curve: Curves.easeInOut,
                                          ),
                                      const SizedBox(width: 8),
                                      _buildDecorativeBalloon(
                                        AppColors.primaryBlue,
                                        12,
                                        1.0,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Balloon Kingdom',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                      letterSpacing: 0.8,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.white,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ).animate().scale(
                                    duration: 400.ms,
                                    curve: Curves.elasticOut,
                                  ),

                                  // Web Download Banner (Web Only)
                                  if (kIsWeb) ...[
                                    const SizedBox(height: 10),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              Color(0xFF388E3C),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.android_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            const SizedBox(width: 10),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Get Android App',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Release APK (${ApkDownloadHelper.fileSize})',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            BouncyButton(
                                              minWidth: 100,
                                              minHeight: 36,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              backgroundColor: const Color(
                                                0xFFFFD54F,
                                              ),
                                              onTap: () {
                                                SoundManager.instance
                                                    .playRewardSound();
                                                ApkDownloadHelper.downloadReleaseApk();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '📥 Downloading Balloon Kingdom Release APK (${ApkDownloadHelper.fileSize})... 🚀',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.download_rounded,
                                                    color: Colors.black87,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 18),

                              // 5. Game Mode Buttons
                              // Play Levels -> Opens World Kingdom Map
                              BouncyButton(
                                minWidth: 200,
                                minHeight: 50,
                                backgroundColor: AppColors.vibrantGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  SoundManager.instance.playPopSound();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const WorldSelectScreen(),
                                    ),
                                  );
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.map_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Play Levels',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Learning Mode
                              BouncyButton(
                                minWidth: 200,
                                minHeight: 50,
                                backgroundColor: AppColors.playfulViolet,
                                shadowColor: const Color(0xFF5E35B1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  SoundManager.instance.playPopSound();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LearningModeHubScreen(),
                                    ),
                                  );
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.school_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Learning Mode',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Challenge Mode
                              BouncyButton(
                                minWidth: 200,
                                minHeight: 50,
                                backgroundColor: const Color(0xFFFF7043),
                                shadowColor: const Color(0xFFD84315),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  SoundManager.instance.playPopSound();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ChallengeHubScreen(),
                                    ),
                                  );
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.military_tech_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Challenge Mode',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Mini-Games Hub
                              BouncyButton(
                                minWidth: 200,
                                minHeight: 46,
                                backgroundColor: const Color(0xFF00B0FF),
                                shadowColor: const Color(0xFF0277BD),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  SoundManager.instance.playPopSound();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MiniGamesHubScreen(),
                                    ),
                                  );
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🎮',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Mini-Games',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Free Play
                              BouncyButton(
                                minWidth: 200,
                                minHeight: 44,
                                backgroundColor: AppColors.sunnyGold,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  SoundManager.instance.playPopSound();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const FreePlayScreen(),
                                    ),
                                  );
                                },
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.all_inclusive_rounded,
                                        size: 20,
                                        color: AppColors.textDark,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Free Play',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // 6. Collectibles & Kingdom Features Row 1 (Pets & Stickers)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // My Pets
                                    BouncyButton(
                                      minWidth: 120,
                                      minHeight: 44,
                                      backgroundColor: Colors.white,
                                      shadowColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      onTap: () {
                                        SoundManager.instance.playPopSound();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PetsSanctuaryScreen(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            '🐾',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'My Pets',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Sticker Book
                                    BouncyButton(
                                      minWidth: 120,
                                      minHeight: 44,
                                      backgroundColor: Colors.white,
                                      shadowColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      onTap: () {
                                        SoundManager.instance.playPopSound();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const StickerBookScreen(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            '✨',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Stickers',
                                            style: TextStyle(
                                              fontSize: 15,
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

                              // 7. Features Row 2 (Balloon House & Story Mode)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Balloon House
                                    BouncyButton(
                                      minWidth: 120,
                                      minHeight: 44,
                                      backgroundColor: Colors.white,
                                      shadowColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      onTap: () {
                                        SoundManager.instance.playPopSound();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const BalloonHouseScreen(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            '🏡',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'House',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Story Mode
                                    BouncyButton(
                                      minWidth: 120,
                                      minHeight: 44,
                                      backgroundColor: Colors.white,
                                      shadowColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      onTap: () {
                                        SoundManager.instance.playPopSound();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const StoryModeScreen(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            '🏰',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Story',
                                            style: TextStyle(
                                              fontSize: 15,
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

                              // AdMob banner (unless Deluxe Pass is unlocked)
                              if (!playerProfile.isPremiumUnlocked)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ref
                                      .watch(adServiceProvider)
                                      .getBannerAdWidget(),
                                ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

  Widget _buildDecorativeBalloon(
    Color color,
    double rotateDegrees,
    double scale,
  ) {
    return Transform.rotate(
      angle: rotateDegrees * (math.pi / 180),
      child: Container(
        width: 30 * scale,
        height: 38 * scale,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.elliptical(30, 38)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(120),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
