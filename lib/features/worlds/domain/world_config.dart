import 'package:flutter/material.dart';
import '../../gameplay/domain/models/balloon_type.dart';
import '../../gameplay/domain/models/level_config.dart';

class WorldConfig {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final int starRequirement;
  final List<Color> themeColors;
  final List<Color> balloonPalette;
  final String backgroundAsset;
  final String musicTrack;
  final String decorativeType; // 'cloud', 'bubble', 'star', 'leaf', 'candy', 'snowflake'
  final List<LevelConfig> levels;

  const WorldConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.starRequirement,
    required this.themeColors,
    required this.balloonPalette,
    required this.backgroundAsset,
    required this.musicTrack,
    required this.decorativeType,
    required this.levels,
  });

  static List<WorldConfig> getAllWorlds() {
    return [
      sunnySky(),
      oceanKingdom(),
      spaceWorld(),
      dinosaurValley(),
      candyLand(),
      winterWonderland(),
    ];
  }

  // 1. Sunny Sky (World 1: 0 stars)
  static WorldConfig sunnySky() {
    return WorldConfig(
      id: 'sunny_sky',
      name: 'Sunny Sky',
      emoji: '☀️',
      icon: Icons.wb_sunny_rounded,
      starRequirement: 0,
      themeColors: const [Color(0xFF42A5F5), Color(0xFF90CAF9), Color(0xFFE3F2FD)],
      balloonPalette: const [
        Color(0xFFFF3366),
        Color(0xFFFF6D00),
        Color(0xFFFFD600),
        Color(0xFF00E676),
        Color(0xFF00B0FF),
        Color(0xFF7C4DFF),
      ],
      backgroundAsset: 'assets/images/worlds/sunny_sky.png',
      musicTrack: 'audio/music/sunny_sky.mp3',
      decorativeType: 'cloud',
      levels: _generateLevels(
        worldId: 'sunny_sky',
        baseSpeed: 90.0,
        baseTarget: 15,
        allowedTypes: [BalloonType.normal, BalloonType.golden, BalloonType.rainbow, BalloonType.bomb],
      ),
    );
  }

  // 2. Ocean Kingdom (World 2: 20 stars)
  static WorldConfig oceanKingdom() {
    return WorldConfig(
      id: 'ocean_kingdom',
      name: 'Ocean Kingdom',
      emoji: '🌊',
      icon: Icons.waves_rounded,
      starRequirement: 20,
      themeColors: const [Color(0xFF004D40), Color(0xFF00897B), Color(0xFF80CBC4)],
      balloonPalette: const [
        Color(0xFF00E5FF),
        Color(0xFF1DE9B6),
        Color(0xFF00B0FF),
        Color(0xFF00BFA5),
        Color(0xFFFF7043),
        Color(0xFFE0F7FA),
      ],
      backgroundAsset: 'assets/images/worlds/ocean_kingdom.png',
      musicTrack: 'audio/music/ocean_kingdom.mp3',
      decorativeType: 'bubble',
      levels: _generateLevels(
        worldId: 'ocean_kingdom',
        baseSpeed: 100.0,
        baseTarget: 18,
        allowedTypes: [BalloonType.normal, BalloonType.frozen, BalloonType.time, BalloonType.golden, BalloonType.bomb],
      ),
    );
  }

  // 3. Space World (World 3: 45 stars)
  static WorldConfig spaceWorld() {
    return WorldConfig(
      id: 'space_world',
      name: 'Space World',
      emoji: '🚀',
      icon: Icons.rocket_launch_rounded,
      starRequirement: 45,
      themeColors: const [Color(0xFF0D47A1), Color(0xFF311B92), Color(0xFF4A148C)],
      balloonPalette: const [
        Color(0xFFE040FB),
        Color(0xFF7C4DFF),
        Color(0xFF00E5FF),
        Color(0xFFFFD600),
        Color(0xFFFF4081),
      ],
      backgroundAsset: 'assets/images/worlds/space_world.png',
      musicTrack: 'audio/music/space_world.mp3',
      decorativeType: 'star',
      levels: _generateLevels(
        worldId: 'space_world',
        baseSpeed: 110.0,
        baseTarget: 20,
        allowedTypes: [BalloonType.normal, BalloonType.rocket, BalloonType.magic, BalloonType.bomb],
      ),
    );
  }

  // 4. Dinosaur Valley (World 4: 70 stars)
  static WorldConfig dinosaurValley() {
    return WorldConfig(
      id: 'dinosaur_valley',
      name: 'Dinosaur Valley',
      emoji: '🦕',
      icon: Icons.forest_rounded,
      starRequirement: 70,
      themeColors: const [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF81C784)],
      balloonPalette: const [
        Color(0xFF00E676),
        Color(0xFFFF6D00),
        Color(0xFFFFD600),
        Color(0xFF8D6E63),
        Color(0xFF76FF03),
      ],
      backgroundAsset: 'assets/images/worlds/dinosaur_valley.png',
      musicTrack: 'audio/music/dinosaur_valley.mp3',
      decorativeType: 'leaf',
      levels: _generateLevels(
        worldId: 'dinosaur_valley',
        baseSpeed: 115.0,
        baseTarget: 22,
        allowedTypes: [BalloonType.normal, BalloonType.gift, BalloonType.bomb, BalloonType.golden],
      ),
    );
  }

  // 5. Candy Land (World 5: 95 stars)
  static WorldConfig candyLand() {
    return WorldConfig(
      id: 'candy_land',
      name: 'Candy Land',
      emoji: '🍭',
      icon: Icons.cake_rounded,
      starRequirement: 95,
      themeColors: const [Color(0xFFD81B60), Color(0xFFF06292), Color(0xFFFCE4EC)],
      balloonPalette: const [
        Color(0xFFFF4081),
        Color(0xFFFF80AB),
        Color(0xFFFFD54F),
        Color(0xFFB388FF),
        Color(0xFF80D8FF),
      ],
      backgroundAsset: 'assets/images/worlds/candy_land.png',
      musicTrack: 'audio/music/candy_land.mp3',
      decorativeType: 'candy',
      levels: _generateLevels(
        worldId: 'candy_land',
        baseSpeed: 120.0,
        baseTarget: 24,
        allowedTypes: [BalloonType.normal, BalloonType.rainbow, BalloonType.heart, BalloonType.magic, BalloonType.bomb],
      ),
    );
  }

  // 6. Winter Wonderland (World 6: 120 stars)
  static WorldConfig winterWonderland() {
    return WorldConfig(
      id: 'winter_wonderland',
      name: 'Winter Wonderland',
      emoji: '❄️',
      icon: Icons.ac_unit_rounded,
      starRequirement: 120,
      themeColors: const [Color(0xFF0277BD), Color(0xFF4FC3F7), Color(0xFFE1F5FE)],
      balloonPalette: const [
        Color(0xFF80D8FF),
        Color(0xFF00B0FF),
        Color(0xFFE0F7FA),
        Color(0xFFB39DDB),
        Color(0xFFFFFFFF),
      ],
      backgroundAsset: 'assets/images/worlds/winter_wonderland.png',
      musicTrack: 'audio/music/winter_wonderland.mp3',
      decorativeType: 'snowflake',
      levels: _generateLevels(
        worldId: 'winter_wonderland',
        baseSpeed: 125.0,
        baseTarget: 25,
        allowedTypes: [BalloonType.normal, BalloonType.frozen, BalloonType.time, BalloonType.bomb],
      ),
    );
  }

  static List<LevelConfig> _generateLevels({
    required String worldId,
    required double baseSpeed,
    required int baseTarget,
    required List<BalloonType> allowedTypes,
  }) {
    return List.generate(20, (i) {
      final levelNum = i + 1;
      final speedBonus = i * 3.5;
      final target = baseTarget + (i * 4);

      return LevelConfig(
        worldId: worldId,
        index: levelNum,
        spawnIntervalSeconds: (1.15 - (i * 0.025)).clamp(0.48, 1.15),
        minSpeed: baseSpeed + speedBonus,
        maxSpeed: baseSpeed + speedBonus + 60.0,
        allowedTypes: allowedTypes,
        targetScore: target,
        oneStarThreshold: target ~/ 2,
        twoStarThreshold: target,
        threeStarThreshold: (target * 1.35).toInt(),
      );
    });
  }
}
