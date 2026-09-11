import 'package:balloonpop/core/audio/sound_manager.dart';
import 'package:balloonpop/core/di/providers.dart';
import 'package:balloonpop/features/gameplay/domain/models/level_config.dart';
import 'package:balloonpop/features/gameplay/presentation/providers/gameplay_notifier.dart';
import 'package:balloonpop/features/gameplay/presentation/views/wrong_balloon_dialog.dart';
import 'package:balloonpop/features/rewards/domain/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (call) async => 1,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (call) async => 1,
  );

  group('Avoid Balloon Mechanics and Game Over Flow', () {
    test('Popping Avoid Balloon triggers immediate Game Over with isWrongBalloonGameOver', () {
      final fakeStorage = FakeStorageService();
      final profileNotifier = PlayerProfileNotifier(fakeStorage);
      final rewardService = RewardService(profileNotifier);
      final notifier = GameplayNotifier(rewardService);

      notifier.initSession(
        levelConfig: const LevelConfig(
          worldId: 'sunny_sky',
          index: 5,
          targetScore: 35,
        ),
      );

      expect(notifier.state.isGameOver, isFalse);
      expect(notifier.state.isWrongBalloonGameOver, isFalse);

      // Popping Avoid balloon
      notifier.hitAvoidBalloon();

      expect(notifier.state.isGameOver, isTrue);
      expect(notifier.state.isWrongBalloonGameOver, isTrue);
      expect(notifier.state.lives, 0);

      // Reviving from wrong balloon (e.g. via Second Chance Rewarded Ad)
      notifier.reviveFromWrongBalloon();

      expect(notifier.state.isGameOver, isFalse);
      expect(notifier.state.isWrongBalloonGameOver, isFalse);
    });

    test('hitBomb in Level Mode also triggers Wrong Balloon Game Over', () {
      final fakeStorage = FakeStorageService();
      final profileNotifier = PlayerProfileNotifier(fakeStorage);
      final rewardService = RewardService(profileNotifier);
      final notifier = GameplayNotifier(rewardService);

      notifier.initSession(
        levelConfig: const LevelConfig(
          worldId: 'ocean_kingdom',
          index: 3,
          targetScore: 25,
        ),
      );

      notifier.hitBomb();

      expect(notifier.state.isGameOver, isTrue);
      expect(notifier.state.isWrongBalloonGameOver, isTrue);
    });

    testWidgets('WrongBalloonDialog renders warning, title, stats and actions', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool replayed = false;
      bool exited = false;
      bool revived = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(FakeStorageService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WrongBalloonDialog(
                score: 120,
                poppedCount: 14,
                levelIndex: 4,
                onRevive: () => revived = true,
                onReplay: () => replayed = true,
                onExit: () => exited = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check text elements
      expect(find.text('Wrong Balloon! 💥'), findsOneWidget);
      expect(find.text('Oops! You popped the wrong one!'), findsOneWidget);
      expect(find.text('120 pts'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Level 4'), findsOneWidget);
      expect(find.text('Second Chance! 💖 (Revive)'), findsOneWidget);
      expect(find.text('Try Again 🔄'), findsOneWidget);
      expect(find.text('Exit 🏠'), findsOneWidget);

      // Tap Try Again
      await tester.ensureVisible(find.text('Try Again 🔄'));
      await tester.tap(find.text('Try Again 🔄'));
      await tester.pumpAndSettle();
      expect(replayed, isTrue);

      // Tap Exit
      await tester.ensureVisible(find.text('Exit 🏠'));
      await tester.tap(find.text('Exit 🏠'));
      await tester.pumpAndSettle();
      expect(exited, isTrue);
      expect(revived, isFalse);
    });

    test('SoundManager BGM controls start, pause, resume, volume, and mute', () async {
      await SoundManager.instance.initialize();

      expect(SoundManager.instance.isMusicMuted, isFalse);

      SoundManager.instance.setBgmVolume(0.5);
      expect(SoundManager.instance.bgmVolume, 0.5);

      await SoundManager.instance.startBgm();
      await SoundManager.instance.pauseBgm();
      await SoundManager.instance.resumeBgm();

      SoundManager.instance.toggleMusicMute();
      expect(SoundManager.instance.isMusicMuted, isTrue);

      SoundManager.instance.toggleMusicMute();
      expect(SoundManager.instance.isMusicMuted, isFalse);

      await SoundManager.instance.stopBgm();
    });

    test('SoundManager pauses BGM when device enters sleep mode and resumes on wake', () async {
      await SoundManager.instance.initialize();
      await SoundManager.instance.startBgm();

      // Device sleep mode / lock screen / app backgrounded
      SoundManager.instance.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(SoundManager.instance.isBgmPlaying, isFalse);

      // Device wakes up / unlocked
      SoundManager.instance.didChangeAppLifecycleState(AppLifecycleState.resumed);

      await SoundManager.instance.stopBgm();
    });
  });
}
