import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'balloon_type.dart';

enum MissionType {
  popCount,
  popColor,
  popType,
  targetScore,
}

enum MedalType {
  none,
  bronze,
  silver,
  gold,
}

extension MedalTypeExtension on MedalType {
  String get displayName {
    switch (this) {
      case MedalType.gold:
        return 'Gold Medal';
      case MedalType.silver:
        return 'Silver Medal';
      case MedalType.bronze:
        return 'Bronze Medal';
      case MedalType.none:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case MedalType.gold:
        return const Color(0xFFFFD700);
      case MedalType.silver:
        return const Color(0xFFC0C0C0);
      case MedalType.bronze:
        return const Color(0xFFCD7F32);
      case MedalType.none:
        return Colors.blueGrey;
    }
  }

  IconData get icon {
    switch (this) {
      case MedalType.gold:
      case MedalType.silver:
      case MedalType.bronze:
        return Icons.military_tech_rounded;
      case MedalType.none:
        return Icons.check_circle_rounded;
    }
  }
}

class ChallengeMission {
  final String id;
  final String title;
  final String description;
  final int timeLimitSeconds;
  final MissionType type;
  final int targetCount;
  final Color? targetColor;
  final BalloonType? targetBalloonType;
  final int goldTimeRemaining;
  final int silverTimeRemaining;

  const ChallengeMission({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimitSeconds,
    required this.type,
    required this.targetCount,
    this.targetColor,
    this.targetBalloonType,
    this.goldTimeRemaining = 12,
    this.silverTimeRemaining = 4,
  });

  MedalType calculateMedal(int timeRemaining) {
    if (timeRemaining >= goldTimeRemaining) {
      return MedalType.gold;
    } else if (timeRemaining >= silverTimeRemaining) {
      return MedalType.silver;
    } else {
      return MedalType.bronze;
    }
  }

  static List<ChallengeMission> getDefaultMissions() {
    return [
      const ChallengeMission(
        id: 'mission_1',
        title: 'Balloon Frenzy',
        description: 'Pop 20 balloons as fast as you can!',
        timeLimitSeconds: 30,
        type: MissionType.popCount,
        targetCount: 20,
        goldTimeRemaining: 15,
        silverTimeRemaining: 5,
      ),
      ChallengeMission(
        id: 'mission_2',
        title: 'Red Alert',
        description: 'Pop 10 Red balloons! Watch out for bombs!',
        timeLimitSeconds: 35,
        type: MissionType.popColor,
        targetCount: 10,
        targetColor: AppColors.balloonPalette.first, // Red
        goldTimeRemaining: 14,
        silverTimeRemaining: 5,
      ),
      const ChallengeMission(
        id: 'mission_3',
        title: 'Gold Rush',
        description: 'Collect 4 gleaming Golden balloons!',
        timeLimitSeconds: 40,
        type: MissionType.popType,
        targetCount: 4,
        targetBalloonType: BalloonType.golden,
        goldTimeRemaining: 16,
        silverTimeRemaining: 6,
      ),
      const ChallengeMission(
        id: 'mission_4',
        title: 'Freeze & Pop',
        description: 'Pop 3 Frozen ice balloons to slow time!',
        timeLimitSeconds: 35,
        type: MissionType.popType,
        targetCount: 3,
        targetBalloonType: BalloonType.frozen,
        goldTimeRemaining: 12,
        silverTimeRemaining: 4,
      ),
      const ChallengeMission(
        id: 'mission_5',
        title: 'Score Master',
        description: 'Score 35 points before time runs out!',
        timeLimitSeconds: 40,
        type: MissionType.targetScore,
        targetCount: 35,
        goldTimeRemaining: 18,
        silverTimeRemaining: 7,
      ),
    ];
  }
}
