import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balloonpop/core/audio/sound_manager.dart';
import 'package:balloonpop/core/di/providers.dart';
import 'package:balloonpop/core/storage/storage_service.dart';
import 'package:balloonpop/features/rewards/domain/player_profile.dart';
import 'package:balloonpop/features/home/presentation/home_screen.dart';
import 'package:balloonpop/features/worlds/presentation/world_select_screen.dart';
import 'package:balloonpop/features/worlds/presentation/level_select_screen.dart';
import 'package:balloonpop/features/minigames/presentation/views/mini_games_hub_screen.dart';
import 'package:balloonpop/features/learning/presentation/views/learning_mode_hub_screen.dart';
import 'package:balloonpop/features/house/presentation/views/balloon_house_screen.dart';
import 'package:balloonpop/features/parental/presentation/views/parent_dashboard_screen.dart';
import 'package:balloonpop/features/gameplay/presentation/views/game_hud_overlay.dart';

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
  SoundManager.instance.isMuted = true;

  // Defined multi-device pixel matrix covering mobile, tab, landscape, and desktop/web
  final devicePresets = <String, Size>{
    'iPhone SE 1st Gen (320x568)': const Size(320, 568),
    'Small Android Phone (360x640)': const Size(360, 640),
    'Modern Mobile Portrait (390x844)': const Size(390, 844),
    'Mobile Landscape (640x360)': const Size(640, 360),
    'Mobile Landscape Wide (844x390)': const Size(844, 390),
    'Tablet iPad Portrait (768x1024)': const Size(768, 1024),
    'Tablet iPad Landscape (1024x768)': const Size(1024, 768),
    'Desktop & Web Full HD (1920x1080)': const Size(1920, 1080),
  };

  Widget buildTestScope({required Widget child}) {
    return ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(FakeStorageService()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Multi-Device Responsive Matrix Verification (Zero Overflows)', () {
    for (final entry in devicePresets.entries) {
      final deviceName = entry.key;
      final screenSize = entry.value;

      testWidgets('HomeScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const HomeScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'HomeScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('WorldSelectScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const WorldSelectScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'WorldSelectScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('LevelSelectScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const LevelSelectScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'LevelSelectScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('MiniGamesHubScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const MiniGamesHubScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'MiniGamesHubScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('LearningModeHubScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const LearningModeHubScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'LearningModeHubScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('BalloonHouseScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const BalloonHouseScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'BalloonHouseScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('ParentDashboardScreen renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestScope(child: const ParentDashboardScreen()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull,
            reason: 'ParentDashboardScreen threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('GameHudOverlay renders without overflow on $deviceName', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestScope(
            child: Scaffold(
              body: GameHudOverlay(
                onPauseTap: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull,
            reason: 'GameHudOverlay threw an exception on $deviceName');

        await tester.pumpWidget(const SizedBox());
      });
    }
  });
}
