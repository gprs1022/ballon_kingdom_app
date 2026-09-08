import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum BalloonType {
  normal,
  golden,
  rainbow,
  gift,
  rocket,
  frozen,
  time,
  heart,
  magic,
  bomb,
}

class BalloonBehavior {
  final int points;
  final int coinReward;
  final double spawnWeight;
  final double speedMultiplier;
  final String effectDescription;
  final Color primaryColor;
  final Color accentColor;
  final IconData? icon;

  const BalloonBehavior({
    required this.points,
    required this.coinReward,
    required this.spawnWeight,
    required this.speedMultiplier,
    required this.effectDescription,
    required this.primaryColor,
    required this.accentColor,
    this.icon,
  });
}

extension BalloonTypeExtension on BalloonType {
  BalloonBehavior get behavior {
    switch (this) {
      case BalloonType.normal:
        return const BalloonBehavior(
          points: 1,
          coinReward: 1,
          spawnWeight: 0.65,
          speedMultiplier: 1.0,
          effectDescription: 'Pops with colorful confetti and +1 point!',
          primaryColor: AppColors.primaryBlue,
          accentColor: AppColors.cloudWhite,
        );
      case BalloonType.golden:
        return const BalloonBehavior(
          points: 10,
          coinReward: 10,
          spawnWeight: 0.08,
          speedMultiplier: 1.3,
          effectDescription: 'Shining gold! Grants +10 bonus coins!',
          primaryColor: AppColors.goldAccent,
          accentColor: Color(0xFFFFF9C4),
          icon: Icons.star_rounded,
        );
      case BalloonType.rainbow:
        return const BalloonBehavior(
          points: 5,
          coinReward: 3,
          spawnWeight: 0.05,
          speedMultiplier: 1.15,
          effectDescription: 'Chain burst! Triggers rainbow pop cascade.',
          primaryColor: AppColors.candyPink,
          accentColor: AppColors.playfulViolet,
          icon: Icons.looks_rounded,
        );
      case BalloonType.gift:
        return const BalloonBehavior(
          points: 3,
          coinReward: 5,
          spawnWeight: 0.05,
          speedMultiplier: 0.9,
          effectDescription: 'Treasure chest balloon! Unlocks surprise rewards.',
          primaryColor: AppColors.softAmber,
          accentColor: AppColors.sunnyGold,
          icon: Icons.card_giftcard_rounded,
        );
      case BalloonType.rocket:
        return const BalloonBehavior(
          points: 2,
          coinReward: 2,
          spawnWeight: 0.04,
          speedMultiplier: 1.6,
          effectDescription: 'Zooms upward rapidly and clears nearby balloons!',
          primaryColor: AppColors.coralRed,
          accentColor: AppColors.softAmber,
          icon: Icons.rocket_launch_rounded,
        );
      case BalloonType.frozen:
        return const BalloonBehavior(
          points: 1,
          coinReward: 1,
          spawnWeight: 0.03,
          speedMultiplier: 0.6,
          effectDescription: 'Slows down time for all floating balloons.',
          primaryColor: Color(0xFF80D8FF),
          accentColor: Colors.white,
          icon: Icons.ac_unit_rounded,
        );
      case BalloonType.time:
        return const BalloonBehavior(
          points: 2,
          coinReward: 2,
          spawnWeight: 0.03,
          speedMultiplier: 1.1,
          effectDescription: 'Adds +10 seconds to Challenge Mode timer!',
          primaryColor: Color(0xFF00E676),
          accentColor: Colors.white,
          icon: Icons.timer_rounded,
        );
      case BalloonType.heart:
        return const BalloonBehavior(
          points: 5,
          coinReward: 2,
          spawnWeight: 0.03,
          speedMultiplier: 0.95,
          effectDescription: 'Gentle extra life heart balloon.',
          primaryColor: Color(0xFFFF4081),
          accentColor: Colors.white,
          icon: Icons.favorite_rounded,
        );
      case BalloonType.magic:
        return const BalloonBehavior(
          points: 5,
          coinReward: 4,
          spawnWeight: 0.02,
          speedMultiplier: 1.2,
          effectDescription: 'Mystic sparkle transformation surprise!',
          primaryColor: AppColors.richPurple,
          accentColor: Color(0xFFE040FB),
          icon: Icons.auto_awesome_rounded,
        );
      case BalloonType.bomb:
        return const BalloonBehavior(
          points: 0,
          coinReward: 0,
          spawnWeight: 0.02,
          speedMultiplier: 0.85,
          effectDescription: 'Pops with a soft, gentle puff of cloud (non-violent).',
          primaryColor: AppColors.bombBody,
          accentColor: AppColors.bombPuff,
          icon: Icons.cloud_rounded,
        );
    }
  }
}
