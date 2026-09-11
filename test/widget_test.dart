import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balloonpop/core/audio/sound_manager.dart';
import 'package:balloonpop/core/storage/storage_service.dart';
import 'package:balloonpop/features/rewards/domain/player_profile.dart';
import 'package:balloonpop/features/rewards/domain/reward_service.dart';
import 'package:balloonpop/features/gameplay/domain/models/balloon_type.dart';
import 'package:balloonpop/features/gameplay/domain/models/challenge_mission.dart';
import 'package:balloonpop/features/gameplay/domain/models/level_config.dart';
import 'package:balloonpop/features/gameplay/presentation/providers/gameplay_notifier.dart';
import 'package:balloonpop/features/learning/domain/models/learning_item.dart';
import 'package:balloonpop/features/learning/domain/services/learning_content_provider.dart';
import 'package:balloonpop/features/pets/domain/pet.dart';
import 'package:balloonpop/features/rewards/domain/sticker_catalog.dart';
import 'package:balloonpop/features/worlds/domain/world_config.dart';
import 'package:balloonpop/features/house/domain/house_catalog.dart';
import 'package:balloonpop/features/minigames/domain/minigame_config.dart';
import 'package:balloonpop/features/shop/domain/theme_model.dart';
import 'package:balloonpop/features/story/domain/kingdom_story_model.dart';
import 'package:balloonpop/core/monetization/ad_service.dart';
import 'package:balloonpop/core/monetization/iap_service.dart';
import 'package:balloonpop/features/parental/presentation/views/parent_gate_dialog.dart';
import 'package:balloonpop/core/utils/apk_download_helper.dart';

class FakeStorageService implements StorageService {
  PlayerProfile profile = const PlayerProfile();

  @override
  PlayerProfile loadPlayerProfile() => profile;

  @override
  Future<void> savePlayerProfile(PlayerProfile p) async {
    profile = p;
  }

  @override
  bool get soundEnabled => true;

  @override
  Future<void> setSoundEnabled(bool enabled) async {}

  @override
  Future<void> initialize() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SoundManager.instance.isMuted =
      true; // Avoid platform audio calls during headless unit tests

  group('PlayerProfile Model Tests', () {
    test('Default profile has proper initial progression values', () {
      const profile = PlayerProfile();
      expect(profile.coins, 0);
      expect(profile.stars, 0);
      expect(profile.xp, 0);
      expect(profile.level, 1);
      expect(profile.highestUnlockedLevel, 1);
      expect(profile.levelStars.isEmpty, isTrue);
      expect(profile.unlockedWorlds, contains('sunny_sky'));
    });

    test(
      'PlayerProfile JSON serialization round-trip with levelStars works',
      () {
        const profile = PlayerProfile(
          coins: 150,
          stars: 12,
          xp: 220,
          level: 3,
          highestUnlockedLevel: 5,
          levelStars: {'sunny_sky_1': 3, 'sunny_sky_2': 2},
        );

        final json = profile.toJson();
        final restored = PlayerProfile.fromJson(json);

        expect(restored.coins, 150);
        expect(restored.stars, 12);
        expect(restored.highestUnlockedLevel, 5);
        expect(restored.levelStars['sunny_sky_1'], 3);
        expect(restored.levelStars['sunny_sky_2'], 2);
      },
    );
  });

  group('RewardService & Progression Tests', () {
    test(
      'Calculates 3 stars when exceeding 3-star threshold and unlocks next level',
      () async {
        final fakeStorage = FakeStorageService();
        final notifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(notifier);

        const level = LevelConfig(
          worldId: 'sunny_sky',
          index: 1,
          targetScore: 20,
          oneStarThreshold: 10,
          twoStarThreshold: 20,
          threeStarThreshold: 30,
        );

        final result = await rewardService.onLevelCompleted(
          levelConfig: level,
          finalScore: 35,
          bonusCoins: 20,
        );

        expect(result.starsEarned, 3);
        expect(result.coinsGranted, 20);
        expect(result.unlockedNextLevel, isTrue);

        final updatedProfile = notifier.state;
        expect(updatedProfile.coins, 20);
        expect(updatedProfile.stars, 3);
        expect(updatedProfile.highestUnlockedLevel, 2);
        expect(updatedProfile.levelStars['sunny_sky_1'], 3);
      },
    );

    test(
      'Calculates 2 stars when between two-star and three-star threshold',
      () async {
        final fakeStorage = FakeStorageService();
        final notifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(notifier);

        const level = LevelConfig(
          worldId: 'sunny_sky',
          index: 1,
          targetScore: 20,
          oneStarThreshold: 10,
          twoStarThreshold: 20,
          threeStarThreshold: 30,
        );

        final result = await rewardService.onLevelCompleted(
          levelConfig: level,
          finalScore: 24,
        );

        expect(result.starsEarned, 2);
      },
    );

    test('Detects level-up when XP crosses 100 threshold', () async {
      final fakeStorage = FakeStorageService();
      fakeStorage.profile = const PlayerProfile(xp: 80, level: 1);
      final notifier = PlayerProfileNotifier(fakeStorage);
      final rewardService = RewardService(notifier);

      const level = LevelConfig(worldId: 'sunny_sky', index: 1);
      final result = await rewardService.onLevelCompleted(
        levelConfig: level,
        finalScore: 20,
      );

      expect(result.didLevelUp, isTrue);
      expect(result.newPlayerLevel, 2);
      expect(notifier.state.level, 2);
    });
  });

  group('BalloonType & WorldConfig Tests', () {
    test('All 11 balloon types have defined behaviors', () {
      expect(BalloonType.values.length, 11);
      for (final type in BalloonType.values) {
        expect(type.behavior.spawnWeight, greaterThan(0));
      }
    });

    test('WorldConfig defines all 6 worlds totaling 120 unique levels', () {
      final worlds = WorldConfig.getAllWorlds();
      expect(worlds.length, 6);

      final worldIds = worlds.map((w) => w.id).toList();
      expect(worldIds, [
        'sunny_sky',
        'ocean_kingdom',
        'space_world',
        'dinosaur_valley',
        'candy_land',
        'winter_wonderland',
      ]);

      int totalLevels = 0;
      int previousStarReq = -1;
      for (final w in worlds) {
        expect(w.levels.length, 20);
        totalLevels += w.levels.length;
        expect(w.starRequirement, greaterThan(previousStarReq));
        previousStarReq = w.starRequirement;
        expect(w.balloonPalette.length, greaterThanOrEqualTo(4));
        expect(w.themeColors.length, greaterThanOrEqualTo(2));
      }

      expect(totalLevels, 120);
    });
  });

  group('Learning Mode Content Tests', () {
    test('Letters category contains all 26 alphabets A-Z with phonics', () {
      final letters = LearningContentProvider.getItemsForCategory(
        LearningCategory.letters,
      );
      expect(letters.length, 26);
      expect(letters.first.displaySymbol, 'A');
      expect(letters.first.label, 'Apple');
      expect(letters.last.displaySymbol, 'Z');
      expect(letters.last.label, 'Zebra');
    });

    test('Numbers category contains numbers 1 to 20', () {
      final numbers = LearningContentProvider.getItemsForCategory(
        LearningCategory.numbers,
      );
      expect(numbers.length, 20);
      expect(numbers.first.displaySymbol, '1');
      expect(numbers.last.displaySymbol, '20');
    });

    test(
      'Shapes, Colors, and Animals categories contain rich educational items',
      () {
        final shapes = LearningContentProvider.getItemsForCategory(
          LearningCategory.shapes,
        );
        final colors = LearningContentProvider.getItemsForCategory(
          LearningCategory.colors,
        );
        final animals = LearningContentProvider.getItemsForCategory(
          LearningCategory.animals,
        );

        expect(shapes.length, greaterThanOrEqualTo(8));
        expect(colors.length, greaterThanOrEqualTo(8));
        expect(animals.length, greaterThanOrEqualTo(8));

        for (final item in [...shapes, ...colors, ...animals]) {
          expect(item.label.isNotEmpty, isTrue);
          expect(item.displaySymbol.isNotEmpty, isTrue);
          expect(item.spokenText.isNotEmpty, isTrue);
        }
      },
    );

    test('getRandomItem returns valid item for given category', () {
      final item = LearningContentProvider.getRandomItem(
        LearningCategory.animals,
      );
      expect(item.category, LearningCategory.animals);
      expect(item.label.isNotEmpty, isTrue);
    });
  });

  group('Challenge Mode & Balloon Behaviors Tests', () {
    test('Default missions list contains 5 diverse challenge missions', () {
      final missions = ChallengeMission.getDefaultMissions();
      expect(missions.length, 5);
      for (final m in missions) {
        expect(m.title.isNotEmpty, isTrue);
        expect(m.timeLimitSeconds, greaterThan(0));
        expect(m.targetCount, greaterThan(0));
      }
    });

    test(
      'Medal calculation returns Gold, Silver, and Bronze correctly based on remaining time',
      () {
        const mission = ChallengeMission(
          id: 'test_mission',
          title: 'Speed Pop',
          description: 'Test',
          timeLimitSeconds: 30,
          type: MissionType.popCount,
          targetCount: 15,
          goldTimeRemaining: 15,
          silverTimeRemaining: 5,
        );

        expect(mission.calculateMedal(18), MedalType.gold);
        expect(mission.calculateMedal(15), MedalType.gold);
        expect(mission.calculateMedal(10), MedalType.silver);
        expect(mission.calculateMedal(5), MedalType.silver);
        expect(mission.calculateMedal(2), MedalType.bronze);
      },
    );

    test(
      'GameplayNotifier tracks lives, bomb hits, time bonuses and game over in Challenge Mode',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);
        final gameplayNotifier = GameplayNotifier(rewardService);

        const mission = ChallengeMission(
          id: 'm1',
          title: 'Frenzy',
          description: 'Pop',
          timeLimitSeconds: 25,
          type: MissionType.popCount,
          targetCount: 5,
        );

        gameplayNotifier.initSession(challengeMission: mission);
        expect(gameplayNotifier.state.lives, 3);
        expect(gameplayNotifier.state.timeRemaining, 25);
        expect(gameplayNotifier.state.isGameOver, isFalse);

        // Time bonus
        gameplayNotifier.addTimeBonus(10);
        expect(gameplayNotifier.state.timeRemaining, 35);

        // Bomb hits
        gameplayNotifier.hitBomb();
        expect(gameplayNotifier.state.lives, 2);

        // Heart recovery
        gameplayNotifier.grantHeart();
        expect(gameplayNotifier.state.lives, 3);

        // Multiple bomb hits leading to game over
        gameplayNotifier.hitBomb();
        gameplayNotifier.hitBomb();
        gameplayNotifier.hitBomb();
        expect(gameplayNotifier.state.lives, 0);
        expect(gameplayNotifier.state.isGameOver, isTrue);
      },
    );

    test(
      'Completing challenge mission awards medal and sets isMissionCompleted',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);
        final gameplayNotifier = GameplayNotifier(rewardService);

        const mission = ChallengeMission(
          id: 'm1',
          title: 'Frenzy',
          description: 'Pop',
          timeLimitSeconds: 30,
          type: MissionType.popCount,
          targetCount: 2,
          goldTimeRemaining: 15,
        );

        gameplayNotifier.initSession(challengeMission: mission);

        await gameplayNotifier.onBalloonPoppedDetailed(
          1,
          1,
          BalloonType.normal,
          const Color(0xFF00B0FF),
        );
        expect(gameplayNotifier.state.missionProgress, 1);
        expect(gameplayNotifier.state.isMissionCompleted, isFalse);

        await gameplayNotifier.onBalloonPoppedDetailed(
          1,
          1,
          BalloonType.normal,
          const Color(0xFF00B0FF),
        );
        expect(gameplayNotifier.state.missionProgress, 2);
        expect(gameplayNotifier.state.isMissionCompleted, isTrue);
        expect(gameplayNotifier.state.medalEarned, MedalType.gold);
      },
    );
  });

  group('Pets & Stickers Collectibles Tests', () {
    test(
      '8 pet species presets are defined with unique species and attributes',
      () {
        final species = Pet.getSpeciesPresets();
        expect(species.length, 8);
        final names = species.map((p) => p.species).toSet();
        expect(names.length, 8);
        expect(
          names,
          containsAll([
            'Puppy',
            'Kitten',
            'Dragon',
            'Penguin',
            'Baby Dino',
            'Unicorn',
            'Rabbit',
            'Panda',
          ]),
        );
      },
    );

    test(
      'StickerCatalog contains 8 categories and 32 collectible stickers',
      () {
        expect(StickerCatalog.categories.length, 8);
        expect(StickerCatalog.allStickers.length, 32);

        for (final cat in StickerCatalog.categories) {
          final stickers = StickerCatalog.getStickersForCategory(cat);
          expect(stickers.length, 4);
        }
      },
    );

    test(
      'PlayerProfileNotifier feeds pet, consumes food and levels up pet',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);

        expect(profileNotifier.state.petFood, 8);
        final initialPet = profileNotifier.state.pets.first;
        expect(initialPet.level, 1);

        // Feed pet 3 times (3 food consumed, 3 * 15 = 45 XP > 40 XP -> Level 2!)
        final fed = await profileNotifier.feedPet(initialPet.id, foodAmount: 3);
        expect(fed, isTrue);
        expect(profileNotifier.state.petFood, 5);

        final updatedPet = profileNotifier.state.pets.first;
        expect(updatedPet.level, 2);
        expect(updatedPet.xp, 5);
      },
    );

    test('PlayerProfileNotifier hatches new pet with coins', () async {
      final fakeStorage = FakeStorageService();
      fakeStorage.profile = const PlayerProfile(coins: 100);
      final profileNotifier = PlayerProfileNotifier(fakeStorage);

      expect(profileNotifier.state.pets.length, 1);

      final hatched = await profileNotifier.hatchEgg();
      expect(hatched, isNotNull);
      expect(profileNotifier.state.coins, 60);
      expect(profileNotifier.state.pets.length, 2);
      expect(profileNotifier.state.activePetId, hatched!.id);
    });

    test('Unlocking stickers persists to player profile', () async {
      final fakeStorage = FakeStorageService();
      final profileNotifier = PlayerProfileNotifier(fakeStorage);

      await profileNotifier.unlockSticker('stk_rainbow');
      expect(profileNotifier.state.unlockedStickers, contains('stk_rainbow'));
    });
  });

  group('Phase 7: Mini-Games, House, Story, Daily Rewards, Shop & Themes Tests', () {
    test('Catalogs define all required content for Phase 7', () {
      expect(MiniGameInfo.allGames.length, 8);
      expect(HouseRoomInfo.rooms.length, 5);
      expect(HouseRoomInfo.allDecorItems.isNotEmpty, isTrue);
      expect(KingdomBeat.allBeats.length, 6);
      expect(ThemeSkinPack.allThemes.length, 11);
    });

    test(
      'Daily Rewards claim grants coins & food, advances streak, and blocks duplicate claim',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);

        expect(profileNotifier.state.canClaimDailyReward, isTrue);
        expect(profileNotifier.state.dailyRewardStreak, 0);

        final initialCoins = profileNotifier.state.coins;
        final initialFood = profileNotifier.state.petFood;

        final claimed = await profileNotifier.claimDailyReward();
        expect(claimed, isTrue);
        expect(profileNotifier.state.dailyRewardStreak, 1);
        expect(profileNotifier.state.coins, initialCoins + 15);
        expect(profileNotifier.state.petFood, initialFood + 1);
        expect(profileNotifier.state.canClaimDailyReward, isFalse);

        // Attempting second claim on same day fails
        final doubleClaim = await profileNotifier.claimDailyReward();
        expect(doubleClaim, isFalse);
      },
    );

    test('Balloon House decor customization updates room slots', () async {
      final fakeStorage = FakeStorageService();
      final profileNotifier = PlayerProfileNotifier(fakeStorage);

      final roomDecor = profileNotifier.state.houseRooms['living_room'];
      expect(roomDecor, isNotNull);
      expect(roomDecor!['wallpaper'], 'wp_sunny');

      final updated = await profileNotifier.updateHouseDecor(
        'living_room',
        'wallpaper',
        'wp_rainbow',
        cost: 0,
      );

      expect(updated, isTrue);
      expect(
        profileNotifier.state.houseRooms['living_room']!['wallpaper'],
        'wp_rainbow',
      );
    });

    test('Story mode restores kingdom beat and deducts coins', () async {
      final fakeStorage = FakeStorageService();
      fakeStorage.profile = const PlayerProfile(coins: 100);
      final profileNotifier = PlayerProfileNotifier(fakeStorage);

      expect(
        profileNotifier.state.restoredKingdomBeats['coral_palace'],
        isFalse,
      );

      final restored = await profileNotifier.restoreKingdomBeat(
        'coral_palace',
        cost: 45,
      );
      expect(restored, isTrue);
      expect(profileNotifier.state.coins, 55);
      expect(
        profileNotifier.state.restoredKingdomBeats['coral_palace'],
        isTrue,
      );
    });

    test(
      'Mini-game score recording updates high score and grants rewards',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);

        await profileNotifier.recordMiniGameScore(
          'balloon_rush',
          180,
          coinsEarned: 20,
          xpEarned: 35,
        );

        expect(profileNotifier.state.miniGameScores['balloon_rush'], 180);
        expect(profileNotifier.state.coins, 20);
        expect(profileNotifier.state.xp, 35);
      },
    );

    test('Theme skin pack unlocks and equips to profile', () async {
      final fakeStorage = FakeStorageService();
      fakeStorage.profile = const PlayerProfile(coins: 100);
      final profileNotifier = PlayerProfileNotifier(fakeStorage);

      expect(profileNotifier.state.activeTheme, 'theme_classic');

      final unlocked = await profileNotifier.unlockTheme('theme_halloween', 50);
      expect(unlocked, isTrue);
      expect(profileNotifier.state.coins, 50);
      expect(profileNotifier.state.unlockedThemes, contains('theme_halloween'));
      expect(profileNotifier.state.activeTheme, 'theme_halloween');
    });

    test(
      'PlayerProfile parental and accessibility settings serialization round-trip',
      () {
        const profile = PlayerProfile(
          isPremiumUnlocked: true,
          playTimeMinutes: 45,
          screenTimeLimitMinutes: 30,
          isHighContrastMode: true,
          isColorblindSafeMode: true,
          isVoiceNarrationEnabled: false,
          selectedLanguage: 'es',
        );

        final json = profile.toJson();
        final restored = PlayerProfile.fromJson(json);

        expect(restored.isPremiumUnlocked, isTrue);
        expect(restored.playTimeMinutes, 45);
        expect(restored.screenTimeLimitMinutes, 30);
        expect(restored.isHighContrastMode, isTrue);
        expect(restored.isColorblindSafeMode, isTrue);
        expect(restored.isVoiceNarrationEnabled, isFalse);
        expect(restored.selectedLanguage, 'es');
      },
    );

    test(
      'RewardService.unlockPremiumDeluxe unlocks all themes and awards bonus coins',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);

        expect(profileNotifier.state.isPremiumUnlocked, isFalse);
        final initialCoins = profileNotifier.state.coins;

        await rewardService.unlockPremiumDeluxe();

        expect(profileNotifier.state.isPremiumUnlocked, isTrue);
        expect(profileNotifier.state.coins, initialCoins + 500);
        expect(profileNotifier.state.unlockedThemes.length, 11);
        expect(profileNotifier.state.unlockedThemes, contains('theme_crown'));
        expect(profileNotifier.state.unlockedThemes, contains('theme_space'));
      },
    );

    test(
      'OfflineIAPService buyDeluxePass and restorePurchases unlock premium',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);
        final iapService = OfflineIAPService(rewardService);

        expect(profileNotifier.state.isPremiumUnlocked, isFalse);

        final buySuccess = await iapService.buyDeluxePass();
        expect(buySuccess, isTrue);
        expect(profileNotifier.state.isPremiumUnlocked, isTrue);

        final restoreSuccess = await iapService.restorePurchases();
        expect(restoreSuccess, isTrue);
        expect(profileNotifier.state.isPremiumUnlocked, isTrue);
      },
    );

    test(
      'RewardService.unlockDeluxeWithCoins requires 10000 coins and unlocks deluxe',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);

        // Initially 0 coins, unlock should fail
        expect(profileNotifier.state.coins, 0);
        final failUnlock = await rewardService.unlockDeluxeWithCoins(coinCost: 10000);
        expect(failUnlock, isFalse);
        expect(profileNotifier.state.isPremiumUnlocked, isFalse);

        // Grant 12,000 coins
        await profileNotifier.addRewards(coins: 12000);
        expect(profileNotifier.state.coins, 12000);

        // Now unlock with 10,000 coins
        final success = await rewardService.unlockDeluxeWithCoins(coinCost: 10000);
        expect(success, isTrue);
        expect(profileNotifier.state.isPremiumUnlocked, isTrue);
        expect(profileNotifier.state.coins, 2000); // 12000 - 10000
        expect(profileNotifier.state.unlockedThemes, contains('theme_crown'));
      },
    );

    test(
      'Parental settings and playtime tracking updates state correctly',
      () async {
        final fakeStorage = FakeStorageService();
        final profileNotifier = PlayerProfileNotifier(fakeStorage);
        final rewardService = RewardService(profileNotifier);

        expect(profileNotifier.state.screenTimeLimitMinutes, 0);
        expect(profileNotifier.state.isHighContrastMode, isFalse);
        expect(profileNotifier.state.isColorblindSafeMode, isFalse);

        await rewardService.updateParentalSettings(
          screenTimeLimitMinutes: 20,
          isHighContrastMode: true,
          isColorblindSafeMode: true,
          isVoiceNarrationEnabled: false,
        );

        expect(profileNotifier.state.screenTimeLimitMinutes, 20);
        expect(profileNotifier.state.isHighContrastMode, isTrue);
        expect(profileNotifier.state.isColorblindSafeMode, isTrue);
        expect(profileNotifier.state.isVoiceNarrationEnabled, isFalse);

        final initialPlayTime = profileNotifier.state.playTimeMinutes;
        await rewardService.addPlayTime(15);
        expect(profileNotifier.state.playTimeMinutes, initialPlayTime + 15);

        await rewardService.resetProgress();
        expect(profileNotifier.state.playTimeMinutes, 0);
        expect(profileNotifier.state.screenTimeLimitMinutes, 0);
        expect(profileNotifier.state.isPremiumUnlocked, isFalse);
      },
    );

    testWidgets(
      'ParentGateDialog displays math problem and triggers callback on correct answer',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool passedGate = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          ParentGateDialog(onSuccess: () => passedGate = true),
                    );
                  },
                  child: const Text('Open Gate'),
                ),
              ),
            ),
          ),
        );

        // Open dialog
        await tester.tap(find.text('Open Gate'));
        await tester.pumpAndSettle();

        expect(find.text('Parents Only 🛡️'), findsOneWidget);

        // Find the math formula text widget, e.g. "X + Y = ?"
        final mathFinder = find.byWidgetPredicate((widget) {
          if (widget is Text &&
              widget.data != null &&
              widget.data!.contains('+') &&
              widget.data!.contains('=')) {
            return true;
          }
          return false;
        });
        expect(mathFinder, findsOneWidget);

        final mathText = (tester.widget(mathFinder) as Text).data!;
        final parts = mathText
            .replaceAll('=', '')
            .replaceAll('?', '')
            .split('+');
        final num1 = int.parse(parts[0].trim());
        final num2 = int.parse(parts[1].trim());
        final sum = num1 + num2;

        // Tap the button matching the sum
        final answerButton = find.widgetWithText(ElevatedButton, '$sum');
        expect(answerButton, findsOneWidget);

        await tester.tap(answerButton);
        await tester.pumpAndSettle();

        expect(passedGate, isTrue);
        expect(find.text('Parents Only 🛡️'), findsNothing);
      },
    );

    test('AdMobUnitIds exposes valid Google AdMob sample test IDs', () {
      expect(AdMobUnitIds.bannerAdUnitId, isNotEmpty);
      expect(AdMobUnitIds.interstitialAdUnitId, isNotEmpty);
      expect(AdMobUnitIds.rewardedAdUnitId, isNotEmpty);
      expect(
        AdMobUnitIds.bannerAdUnitId,
        contains('ca-app-pub-3940256099942544'),
      );
      expect(
        AdMobUnitIds.interstitialAdUnitId,
        contains('ca-app-pub-3940256099942544'),
      );
      expect(
        AdMobUnitIds.rewardedAdUnitId,
        contains('ca-app-pub-3940256099942544'),
      );
    });

    testWidgets('Ads stay hidden before consent and initialization', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: AdMobService.instance.getBannerAdWidget()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(AdMobService.instance.isAdAvailable, isFalse);
      expect(find.text('Test Ad'), findsNothing);
      expect(find.text('Nice Job! 🎈 Test Ad'), findsNothing);
    });

    test('ApkDownloadHelper defines correct release APK artifact metadata', () {
      expect(ApkDownloadHelper.apkFileName, 'balloon_kingdom.apk');
      expect(ApkDownloadHelper.fileSize, '51.3 MB');
      expect(ApkDownloadHelper.version, contains('Release'));
      expect(ApkDownloadHelper.apkDisplayName, contains('Balloon Kingdom'));
    });
  });
}
