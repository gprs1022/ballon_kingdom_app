import 'balloon_type.dart';

class LevelConfig {
  final String worldId;
  final int index;
  final double spawnIntervalSeconds;
  final double minSpeed;
  final double maxSpeed;
  final List<BalloonType> allowedTypes;
  final int targetScore;
  final int oneStarThreshold;
  final int twoStarThreshold;
  final int threeStarThreshold;

  const LevelConfig({
    required this.worldId,
    required this.index,
    this.spawnIntervalSeconds = 1.0,
    this.minSpeed = 90.0,
    this.maxSpeed = 150.0,
    this.allowedTypes = const [BalloonType.normal, BalloonType.golden],
    this.targetScore = 20,
    this.oneStarThreshold = 10,
    this.twoStarThreshold = 20,
    this.threeStarThreshold = 30,
  });
}
