import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../domain/models/challenge_mission.dart';
import 'gameplay_screen.dart';

class ChallengeHubScreen extends StatelessWidget {
  const ChallengeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.startBgm();
    });

    final missions = ChallengeMission.getDefaultMissions();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Vibrant Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF8A65), // Warm sunset orange
                  Color(0xFFFFCC80),
                  Color(0xFFFFF8E1),
                ],
              ),
            ),
          ),

          // 2. Decorative clouds
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

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                // Top Nav Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      BouncyButton(
                        minWidth: 48,
                        minHeight: 48,
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textDark, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Challenge Missions',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Beat the clock & earn shiny medals!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Missions List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: missions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final mission = missions[index];
                      return _buildMissionCard(context, mission, index);
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

  Widget _buildMissionCard(BuildContext context, ChallengeMission mission, int index) {
    return BouncyButton(
      minHeight: 90,
      backgroundColor: Colors.white,
      shadowColor: const Color(0x30000000),
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      onTap: () {
        SoundManager.instance.playPopSound();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameplayScreen(challengeMission: mission),
          ),
        );
      },
      child: Row(
        children: [
          // Medal / Target Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.sunnyGold.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              color: AppColors.softAmber,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          // Mission Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mission.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mission.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark.withAlpha(160),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_rounded, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${mission.timeLimitSeconds}s Limit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Play button
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.vibrantGreen,
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
