import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/storage/storage_service.dart';
import '../../gameplay/domain/models/level_config.dart';
import '../../pets/domain/pet.dart';
import 'player_profile.dart';

class LevelCompleteResult {
  final int starsEarned;
  final int coinsGranted;
  final int xpGranted;
  final bool didLevelUp;
  final int newPlayerLevel;
  final bool unlockedNextLevel;

  const LevelCompleteResult({
    required this.starsEarned,
    required this.coinsGranted,
    required this.xpGranted,
    required this.didLevelUp,
    required this.newPlayerLevel,
    required this.unlockedNextLevel,
  });
}

class PlayerProfileNotifier extends StateNotifier<PlayerProfile> {
  final StorageService _storageService;

  PlayerProfileNotifier(this._storageService)
      : super(_storageService.loadPlayerProfile());

  Future<LevelCompleteResult> recordLevelCompletion({
    required LevelConfig levelConfig,
    required int finalScore,
    int bonusCoins = 15,
  }) async {
    int stars = 1;
    if (finalScore >= levelConfig.threeStarThreshold) {
      stars = 3;
    } else if (finalScore >= levelConfig.twoStarThreshold) {
      stars = 2;
    }

    final levelKey = '${levelConfig.worldId}_${levelConfig.index}';
    final previousStars = state.levelStars[levelKey] ?? 0;
    final starDelta = stars > previousStars ? (stars - previousStars) : 0;

    final updatedStarsMap = Map<String, int>.from(state.levelStars);
    if (stars > previousStars) {
      updatedStarsMap[levelKey] = stars;
    }

    bool unlockedNext = false;
    int nextHighest = state.highestUnlockedLevel;
    if (levelConfig.index == state.highestUnlockedLevel && levelConfig.index < 20) {
      nextHighest = levelConfig.index + 1;
      unlockedNext = true;
    }

    const xpGranted = 60;
    final oldLevel = state.level;
    final newXp = state.xp + xpGranted;
    final newLevel = 1 + (newXp ~/ 100);
    final didLevelUp = newLevel > oldLevel;

    // Grant +2 pet food on level clear!
    final updatedPetFood = state.petFood + 2;

    state = state.copyWith(
      coins: state.coins + bonusCoins,
      stars: state.stars + starDelta,
      xp: newXp,
      level: newLevel,
      levelStars: updatedStarsMap,
      highestUnlockedLevel: nextHighest,
      petFood: updatedPetFood,
    );

    await _storageService.savePlayerProfile(state);

    return LevelCompleteResult(
      starsEarned: stars,
      coinsGranted: bonusCoins,
      xpGranted: xpGranted,
      didLevelUp: didLevelUp,
      newPlayerLevel: newLevel,
      unlockedNextLevel: unlockedNext,
    );
  }

  Future<void> addRewards({
    int coins = 0,
    int stars = 0,
    int xp = 0,
    int balloons = 0,
    int petFood = 0,
  }) async {
    final newXp = state.xp + xp;
    final newLevel = 1 + (newXp ~/ 100);

    state = state.copyWith(
      coins: state.coins + coins,
      stars: state.stars + stars,
      xp: newXp,
      level: newLevel,
      totalBalloonsPopped: state.totalBalloonsPopped + balloons,
      petFood: state.petFood + petFood,
    );

    await _storageService.savePlayerProfile(state);
  }

  Future<bool> feedPet(String petId, {int foodAmount = 1}) async {
    if (state.petFood < foodAmount) return false;

    final petIndex = state.pets.indexWhere((p) => p.id == petId);
    if (petIndex == -1) return false;

    final currentPet = state.pets[petIndex];
    final addedXp = foodAmount * 15;
    int newXp = currentPet.xp + addedXp;
    int newLevel = currentPet.level;

    while (newXp >= (newLevel * 40) && newLevel < currentPet.maxLevel) {
      newXp -= (newLevel * 40);
      newLevel += 1;
    }

    final updatedPet = currentPet.copyWith(
      level: newLevel,
      xp: newXp,
      animationSet: 'happy',
    );

    final updatedPetsList = List<Pet>.from(state.pets);
    updatedPetsList[petIndex] = updatedPet;

    state = state.copyWith(
      petFood: state.petFood - foodAmount,
      pets: updatedPetsList,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  Future<Pet?> hatchEgg() async {
    const eggCost = 40;
    if (state.coins < eggCost) return null;

    final presets = Pet.getSpeciesPresets();
    final ownedIds = state.pets.map((p) => p.id).toSet();
    final unowned = presets.where((p) => !ownedIds.contains(p.id)).toList();

    if (unowned.isEmpty) return null;

    final newPet = unowned.first;
    final updatedList = List<Pet>.from(state.pets)..add(newPet);

    state = state.copyWith(
      coins: state.coins - eggCost,
      pets: updatedList,
      activePetId: newPet.id,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return newPet;
  }

  Future<void> setActivePet(String petId) async {
    state = state.copyWith(activePetId: petId);
    await _storageService.savePlayerProfile(state);
  }

  Future<void> unlockSticker(String stickerId) async {
    if (!state.unlockedStickers.contains(stickerId)) {
      final updated = List<String>.from(state.unlockedStickers)..add(stickerId);
      state = state.copyWith(unlockedStickers: updated);
      await _storageService.savePlayerProfile(state);
      SoundManager.instance.playRewardSound();
    }
  }

  Future<void> unlockWorld(String worldId) async {
    if (!state.unlockedWorlds.contains(worldId)) {
      final updated = List<String>.from(state.unlockedWorlds)..add(worldId);
      state = state.copyWith(unlockedWorlds: updated);
      await _storageService.savePlayerProfile(state);
    }
  }

  // Phase 7: Daily Rewards
  Future<bool> claimDailyReward() async {
    if (!state.canClaimDailyReward) return false;

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final nextStreak = (state.dailyRewardStreak % 7) + 1;

    int coinsReward = 15;
    int foodReward = 1;
    String? stickerReward;
    String? themeReward;

    switch (nextStreak) {
      case 1:
        coinsReward = 15;
        foodReward = 1;
        break;
      case 2:
        coinsReward = 25;
        foodReward = 2;
        break;
      case 3:
        coinsReward = 40;
        foodReward = 2;
        stickerReward = 'stk_pearl';
        break;
      case 4:
        coinsReward = 50;
        foodReward = 3;
        break;
      case 5:
        coinsReward = 75;
        foodReward = 5;
        break;
      case 6:
        coinsReward = 100;
        foodReward = 6;
        break;
      case 7:
        coinsReward = 150;
        foodReward = 10;
        themeReward = 'theme_crown';
        break;
    }

    final updatedStickers = List<String>.from(state.unlockedStickers);
    if (stickerReward != null && !updatedStickers.contains(stickerReward)) {
      updatedStickers.add(stickerReward);
    }

    final updatedThemes = List<String>.from(state.unlockedThemes);
    if (themeReward != null && !updatedThemes.contains(themeReward)) {
      updatedThemes.add(themeReward);
    }

    state = state.copyWith(
      coins: state.coins + coinsReward,
      petFood: state.petFood + foodReward,
      lastDailyRewardDate: todayStr,
      dailyRewardStreak: nextStreak,
      unlockedStickers: updatedStickers,
      unlockedThemes: updatedThemes,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  // Phase 7: Story Mode Kingdom Restoration
  Future<bool> restoreKingdomBeat(String beatId, {int cost = 50}) async {
    if (state.coins < cost) return false;
    if (state.restoredKingdomBeats[beatId] == true) return false;

    final updatedBeats = Map<String, bool>.from(state.restoredKingdomBeats);
    updatedBeats[beatId] = true;

    state = state.copyWith(
      coins: state.coins - cost,
      restoredKingdomBeats: updatedBeats,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  // Phase 7: House Room Decor Customization
  Future<bool> updateHouseDecor(String roomId, String slot, String itemId, {int cost = 0}) async {
    if (cost > 0 && state.coins < cost) return false;

    final updatedRooms = <String, Map<String, String>>{};
    state.houseRooms.forEach((k, v) {
      updatedRooms[k] = Map<String, String>.from(v);
    });

    if (!updatedRooms.containsKey(roomId)) {
      updatedRooms[roomId] = {};
    }
    updatedRooms[roomId]![slot] = itemId;

    state = state.copyWith(
      coins: state.coins - cost,
      houseRooms: updatedRooms,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  // Phase 7: Mini-Games High Scores & Rewards
  Future<void> recordMiniGameScore(String gameId, int score, {int coinsEarned = 10, int xpEarned = 25}) async {
    final updatedScores = Map<String, int>.from(state.miniGameScores);
    final currentHigh = updatedScores[gameId] ?? 0;
    if (score > currentHigh) {
      updatedScores[gameId] = score;
    }

    final newXp = state.xp + xpEarned;
    final newLevel = 1 + (newXp ~/ 100);

    state = state.copyWith(
      coins: state.coins + coinsEarned,
      xp: newXp,
      level: newLevel,
      petFood: state.petFood + 1,
      miniGameScores: updatedScores,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
  }

  // Phase 7: Themes & Skins
  Future<bool> unlockTheme(String themeId, int cost) async {
    if (state.unlockedThemes.contains(themeId)) return true;
    if (state.coins < cost) return false;

    final updated = List<String>.from(state.unlockedThemes)..add(themeId);
    state = state.copyWith(
      coins: state.coins - cost,
      unlockedThemes: updated,
      activeTheme: themeId,
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  Future<void> equipTheme(String themeId) async {
    if (state.unlockedThemes.contains(themeId)) {
      state = state.copyWith(activeTheme: themeId);
      await _storageService.savePlayerProfile(state);
      SoundManager.instance.playRewardSound();
    }
  }

  // Phase 8: Deluxe Pass & Monetization
  Future<void> unlockPremiumDeluxe() async {
    const allThemes = [
      'theme_classic',
      'theme_rainbow',
      'theme_halloween',
      'theme_christmas',
      'theme_diwali',
      'theme_summer',
      'theme_birthday',
      'theme_jungle',
      'theme_ocean',
      'theme_space',
      'theme_crown',
    ];

    state = state.copyWith(
      isPremiumUnlocked: true,
      coins: state.coins + 500,
      unlockedThemes: allThemes,
      activeTheme: 'theme_crown',
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
  }

  Future<bool> unlockDeluxeWithCoins({int coinCost = 10000}) async {
    if (state.coins < coinCost) return false;

    const allThemes = [
      'theme_classic',
      'theme_rainbow',
      'theme_halloween',
      'theme_christmas',
      'theme_diwali',
      'theme_summer',
      'theme_birthday',
      'theme_jungle',
      'theme_ocean',
      'theme_space',
      'theme_crown',
    ];

    state = state.copyWith(
      isPremiumUnlocked: true,
      coins: state.coins - coinCost,
      unlockedThemes: allThemes,
      activeTheme: 'theme_crown',
    );

    await _storageService.savePlayerProfile(state);
    SoundManager.instance.playRewardSound();
    return true;
  }

  // Phase 8: Parental Controls & Accessibility
  Future<void> updateParentalSettings({
    int? screenTimeLimitMinutes,
    bool? isHighContrastMode,
    bool? isColorblindSafeMode,
    bool? isVoiceNarrationEnabled,
    String? selectedLanguage,
  }) async {
    state = state.copyWith(
      screenTimeLimitMinutes: screenTimeLimitMinutes,
      isHighContrastMode: isHighContrastMode,
      isColorblindSafeMode: isColorblindSafeMode,
      isVoiceNarrationEnabled: isVoiceNarrationEnabled,
      selectedLanguage: selectedLanguage,
    );
    await _storageService.savePlayerProfile(state);
  }

  Future<void> addPlayTime(int minutes) async {
    state = state.copyWith(
      playTimeMinutes: state.playTimeMinutes + minutes,
    );
    await _storageService.savePlayerProfile(state);
  }

  Future<void> resetProgress() async {
    state = const PlayerProfile();
    await _storageService.savePlayerProfile(state);
  }
}

class RewardService {
  final PlayerProfileNotifier _profileNotifier;

  RewardService(this._profileNotifier);

  Future<void> onBalloonPopped({int coins = 1, int points = 1}) async {
    // 1 in 8 balloons also drops pet food!
    final bonusFood = points >= 5 ? 1 : 0;
    await _profileNotifier.addRewards(
      coins: coins,
      xp: points * 2,
      balloons: 1,
      petFood: bonusFood,
    );
  }

  Future<LevelCompleteResult> onLevelCompleted({
    required LevelConfig levelConfig,
    required int finalScore,
    int bonusCoins = 15,
  }) async {
    final result = await _profileNotifier.recordLevelCompletion(
      levelConfig: levelConfig,
      finalScore: finalScore,
      bonusCoins: bonusCoins,
    );
    SoundManager.instance.playRewardSound();
    return result;
  }

  Future<bool> feedPet(String petId, {int foodAmount = 1}) =>
      _profileNotifier.feedPet(petId, foodAmount: foodAmount);

  Future<Pet?> hatchEgg() => _profileNotifier.hatchEgg();

  Future<void> setActivePet(String petId) => _profileNotifier.setActivePet(petId);

  Future<void> unlockSticker(String stickerId) => _profileNotifier.unlockSticker(stickerId);

  // Phase 7 Delegations
  Future<bool> claimDailyReward() => _profileNotifier.claimDailyReward();

  Future<bool> restoreKingdomBeat(String beatId, {int cost = 50}) =>
      _profileNotifier.restoreKingdomBeat(beatId, cost: cost);

  Future<bool> updateHouseDecor(String roomId, String slot, String itemId, {int cost = 0}) =>
      _profileNotifier.updateHouseDecor(roomId, slot, itemId, cost: cost);

  Future<void> recordMiniGameScore(String gameId, int score, {int coinsEarned = 10, int xpEarned = 25}) =>
      _profileNotifier.recordMiniGameScore(gameId, score, coinsEarned: coinsEarned, xpEarned: xpEarned);

  Future<bool> unlockTheme(String themeId, int cost) => _profileNotifier.unlockTheme(themeId, cost);

  Future<void> equipTheme(String themeId) => _profileNotifier.equipTheme(themeId);

  // Phase 8 Delegations
  Future<void> unlockPremiumDeluxe() => _profileNotifier.unlockPremiumDeluxe();

  Future<bool> unlockDeluxeWithCoins({int coinCost = 10000}) =>
      _profileNotifier.unlockDeluxeWithCoins(coinCost: coinCost);

  Future<void> updateParentalSettings({
    int? screenTimeLimitMinutes,
    bool? isHighContrastMode,
    bool? isColorblindSafeMode,
    bool? isVoiceNarrationEnabled,
    String? selectedLanguage,
  }) =>
      _profileNotifier.updateParentalSettings(
        screenTimeLimitMinutes: screenTimeLimitMinutes,
        isHighContrastMode: isHighContrastMode,
        isColorblindSafeMode: isColorblindSafeMode,
        isVoiceNarrationEnabled: isVoiceNarrationEnabled,
        selectedLanguage: selectedLanguage,
      );

  Future<void> addPlayTime(int minutes) => _profileNotifier.addPlayTime(minutes);

  Future<void> resetProgress() => _profileNotifier.resetProgress();
}
