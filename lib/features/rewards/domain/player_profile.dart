import 'package:flutter/material.dart';
import '../../pets/domain/pet.dart';

class PlayerProfile {
  final int coins;
  final int stars;
  final int xp;
  final int level;
  final List<String> unlockedWorlds;
  final List<String> unlockedStickers;
  final int currentStreak;
  final int totalBalloonsPopped;
  final Map<String, int> levelStars; // e.g. {'sunny_sky_1': 3}
  final int highestUnlockedLevel; // In current world (1..20)
  
  // Phase 5: Pets & Collectibles
  final int petFood;
  final List<Pet> pets;
  final String activePetId;

  // Phase 7: Daily Rewards, Balloon House, Story Mode, Themes, Mini-Games
  final String? lastDailyRewardDate;
  final int dailyRewardStreak;
  final Map<String, Map<String, String>> houseRooms;
  final Map<String, bool> restoredKingdomBeats;
  final List<String> unlockedThemes;
  final String activeTheme;
  final Map<String, int> miniGameScores;

  // Phase 8: Parent Dashboard, Accessibility & Monetization
  final bool isPremiumUnlocked;
  final int playTimeMinutes;
  final int screenTimeLimitMinutes; // 0 = unlimited
  final bool isHighContrastMode;
  final bool isColorblindSafeMode;
  final bool isVoiceNarrationEnabled;
  final String selectedLanguage;

  const PlayerProfile({
    this.coins = 0,
    this.stars = 0,
    this.xp = 0,
    this.level = 1,
    this.unlockedWorlds = const ['sunny_sky'],
    this.unlockedStickers = const ['stk_sun', 'stk_puppy'],
    this.currentStreak = 1,
    this.totalBalloonsPopped = 0,
    this.levelStars = const {},
    this.highestUnlockedLevel = 1,
    this.petFood = 8,
    this.pets = const [
      Pet(
        id: 'pet_puppy',
        species: 'Puppy',
        name: 'Barnaby',
        emoji: '🐶',
        primaryColor: Color(0xFF8D6E63),
        accentColor: Color(0xFFFFD54F),
      ),
    ],
    this.activePetId = 'pet_puppy',
    this.lastDailyRewardDate,
    this.dailyRewardStreak = 0,
    this.houseRooms = const {
      'living_room': {
        'wallpaper': 'wp_sunny',
        'flooring': 'fl_wood',
        'furniture': 'fur_sofa',
        'accessory': 'acc_plant',
        'lighting': 'lit_lamp',
      },
      'bed_room': {
        'wallpaper': 'wp_clouds',
        'flooring': 'fl_carpet_blue',
        'furniture': 'fur_bed',
        'accessory': 'acc_bear',
        'lighting': 'lit_star',
      },
      'kitchen': {
        'wallpaper': 'wp_tiles_yellow',
        'flooring': 'fl_tiles',
        'furniture': 'fur_table',
        'accessory': 'acc_fruit',
        'lighting': 'lit_pendant',
      },
      'play_room': {
        'wallpaper': 'wp_rainbow',
        'flooring': 'fl_puzzle',
        'furniture': 'fur_toybox',
        'accessory': 'acc_train',
        'lighting': 'lit_balloons',
      },
      'garden_patio': {
        'wallpaper': 'wp_sky_view',
        'flooring': 'fl_grass',
        'furniture': 'fur_bench',
        'accessory': 'acc_fountain',
        'lighting': 'lit_lanterns',
      },
    },
    this.restoredKingdomBeats = const {
      'sky_castle': true, // First one starts unlocked or partially restored
      'coral_palace': false,
      'rainbow_bridge': false,
      'dino_village': false,
      'candy_forest': false,
      'frost_kingdom': false,
    },
    this.unlockedThemes = const ['theme_classic', 'theme_rainbow'],
    this.activeTheme = 'theme_classic',
    this.miniGameScores = const {},
    this.isPremiumUnlocked = false,
    this.playTimeMinutes = 0,
    this.screenTimeLimitMinutes = 0,
    this.isHighContrastMode = false,
    this.isColorblindSafeMode = false,
    this.isVoiceNarrationEnabled = true,
    this.selectedLanguage = 'en',
  });

  bool get canClaimDailyReward {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastDailyRewardDate != todayStr;
  }

  Pet? get activePet {
    try {
      return pets.firstWhere((p) => p.id == activePetId);
    } catch (_) {
      return pets.isNotEmpty ? pets.first : null;
    }
  }

  PlayerProfile copyWith({
    int? coins,
    int? stars,
    int? xp,
    int? level,
    List<String>? unlockedWorlds,
    List<String>? unlockedStickers,
    int? currentStreak,
    int? totalBalloonsPopped,
    Map<String, int>? levelStars,
    int? highestUnlockedLevel,
    int? petFood,
    List<Pet>? pets,
    String? activePetId,
    String? lastDailyRewardDate,
    int? dailyRewardStreak,
    Map<String, Map<String, String>>? houseRooms,
    Map<String, bool>? restoredKingdomBeats,
    List<String>? unlockedThemes,
    String? activeTheme,
    Map<String, int>? miniGameScores,
    bool? isPremiumUnlocked,
    int? playTimeMinutes,
    int? screenTimeLimitMinutes,
    bool? isHighContrastMode,
    bool? isColorblindSafeMode,
    bool? isVoiceNarrationEnabled,
    String? selectedLanguage,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      stars: stars ?? this.stars,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      currentStreak: currentStreak ?? this.currentStreak,
      totalBalloonsPopped: totalBalloonsPopped ?? this.totalBalloonsPopped,
      levelStars: levelStars ?? this.levelStars,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      petFood: petFood ?? this.petFood,
      pets: pets ?? this.pets,
      activePetId: activePetId ?? this.activePetId,
      lastDailyRewardDate: lastDailyRewardDate ?? this.lastDailyRewardDate,
      dailyRewardStreak: dailyRewardStreak ?? this.dailyRewardStreak,
      houseRooms: houseRooms ?? this.houseRooms,
      restoredKingdomBeats: restoredKingdomBeats ?? this.restoredKingdomBeats,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      activeTheme: activeTheme ?? this.activeTheme,
      miniGameScores: miniGameScores ?? this.miniGameScores,
      isPremiumUnlocked: isPremiumUnlocked ?? this.isPremiumUnlocked,
      playTimeMinutes: playTimeMinutes ?? this.playTimeMinutes,
      screenTimeLimitMinutes: screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      isHighContrastMode: isHighContrastMode ?? this.isHighContrastMode,
      isColorblindSafeMode: isColorblindSafeMode ?? this.isColorblindSafeMode,
      isVoiceNarrationEnabled: isVoiceNarrationEnabled ?? this.isVoiceNarrationEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'stars': stars,
        'xp': xp,
        'level': level,
        'unlockedWorlds': unlockedWorlds,
        'unlockedStickers': unlockedStickers,
        'currentStreak': currentStreak,
        'totalBalloonsPopped': totalBalloonsPopped,
        'levelStars': levelStars,
        'highestUnlockedLevel': highestUnlockedLevel,
        'petFood': petFood,
        'pets': pets.map((p) => p.toJson()).toList(),
        'activePetId': activePetId,
        'lastDailyRewardDate': lastDailyRewardDate,
        'dailyRewardStreak': dailyRewardStreak,
        'houseRooms': houseRooms,
        'restoredKingdomBeats': restoredKingdomBeats,
        'unlockedThemes': unlockedThemes,
        'activeTheme': activeTheme,
        'miniGameScores': miniGameScores,
        'isPremiumUnlocked': isPremiumUnlocked,
        'playTimeMinutes': playTimeMinutes,
        'screenTimeLimitMinutes': screenTimeLimitMinutes,
        'isHighContrastMode': isHighContrastMode,
        'isColorblindSafeMode': isColorblindSafeMode,
        'isVoiceNarrationEnabled': isVoiceNarrationEnabled,
        'selectedLanguage': selectedLanguage,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final rawStars = json['levelStars'];
    final Map<String, int> parsedStars = {};
    if (rawStars is Map) {
      rawStars.forEach((key, value) {
        parsedStars[key.toString()] = (value as num).toInt();
      });
    }

    final rawPets = json['pets'];
    List<Pet> parsedPets = [];
    if (rawPets is List && rawPets.isNotEmpty) {
      parsedPets = rawPets
          .map((item) => Pet.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      parsedPets = [
        const Pet(
          id: 'pet_puppy',
          species: 'Puppy',
          name: 'Barnaby',
          emoji: '🐶',
          primaryColor: Color(0xFF8D6E63),
          accentColor: Color(0xFFFFD54F),
        ),
      ];
    }

    // Parse house rooms
    final rawRooms = json['houseRooms'];
    final Map<String, Map<String, String>> parsedRooms = {};
    if (rawRooms is Map) {
      rawRooms.forEach((rKey, rVal) {
        if (rVal is Map) {
          final Map<String, String> slotMap = {};
          rVal.forEach((sKey, sVal) {
            slotMap[sKey.toString()] = sVal.toString();
          });
          parsedRooms[rKey.toString()] = slotMap;
        }
      });
    }

    // Parse restored kingdom beats
    final rawBeats = json['restoredKingdomBeats'];
    final Map<String, bool> parsedBeats = {};
    if (rawBeats is Map) {
      rawBeats.forEach((bKey, bVal) {
        parsedBeats[bKey.toString()] = bVal == true;
      });
    }

    // Parse miniGameScores
    final rawScores = json['miniGameScores'];
    final Map<String, int> parsedScores = {};
    if (rawScores is Map) {
      rawScores.forEach((gKey, gVal) {
        parsedScores[gKey.toString()] = (gVal as num).toInt();
      });
    }

    return PlayerProfile(
      coins: json['coins'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      unlockedWorlds: (json['unlockedWorlds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['sunny_sky'],
      unlockedStickers: (json['unlockedStickers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['stk_sun', 'stk_puppy'],
      currentStreak: json['currentStreak'] as int? ?? 1,
      totalBalloonsPopped: json['totalBalloonsPopped'] as int? ?? 0,
      levelStars: parsedStars,
      highestUnlockedLevel: json['highestUnlockedLevel'] as int? ?? 1,
      petFood: json['petFood'] as int? ?? 8,
      pets: parsedPets,
      activePetId: json['activePetId'] as String? ?? 'pet_puppy',
      lastDailyRewardDate: json['lastDailyRewardDate'] as String?,
      dailyRewardStreak: json['dailyRewardStreak'] as int? ?? 0,
      houseRooms: parsedRooms.isNotEmpty ? parsedRooms : const {
        'living_room': {
          'wallpaper': 'wp_sunny',
          'flooring': 'fl_wood',
          'furniture': 'fur_sofa',
          'accessory': 'acc_plant',
          'lighting': 'lit_lamp',
        },
        'bed_room': {
          'wallpaper': 'wp_clouds',
          'flooring': 'fl_carpet_blue',
          'furniture': 'fur_bed',
          'accessory': 'acc_bear',
          'lighting': 'lit_star',
        },
        'kitchen': {
          'wallpaper': 'wp_tiles_yellow',
          'flooring': 'fl_tiles',
          'furniture': 'fur_table',
          'accessory': 'acc_fruit',
          'lighting': 'lit_pendant',
        },
        'play_room': {
          'wallpaper': 'wp_rainbow',
          'flooring': 'fl_puzzle',
          'furniture': 'fur_toybox',
          'accessory': 'acc_train',
          'lighting': 'lit_balloons',
        },
        'garden_patio': {
          'wallpaper': 'wp_sky_view',
          'flooring': 'fl_grass',
          'furniture': 'fur_bench',
          'accessory': 'acc_fountain',
          'lighting': 'lit_lanterns',
        },
      },
      restoredKingdomBeats: parsedBeats.isNotEmpty ? parsedBeats : const {
        'sky_castle': true,
        'coral_palace': false,
        'rainbow_bridge': false,
        'dino_village': false,
        'candy_forest': false,
        'frost_kingdom': false,
      },
      unlockedThemes: (json['unlockedThemes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['theme_classic', 'theme_rainbow'],
      activeTheme: json['activeTheme'] as String? ?? 'theme_classic',
      miniGameScores: parsedScores,
      isPremiumUnlocked: json['isPremiumUnlocked'] as bool? ?? false,
      playTimeMinutes: json['playTimeMinutes'] as int? ?? 12,
      screenTimeLimitMinutes: json['screenTimeLimitMinutes'] as int? ?? 0,
      isHighContrastMode: json['isHighContrastMode'] as bool? ?? false,
      isColorblindSafeMode: json['isColorblindSafeMode'] as bool? ?? false,
      isVoiceNarrationEnabled: json['isVoiceNarrationEnabled'] as bool? ?? true,
      selectedLanguage: json['selectedLanguage'] as String? ?? 'en',
    );
  }
}
