import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balloonpop/core/audio/sound_manager.dart';
import 'package:balloonpop/core/di/providers.dart';
import 'package:balloonpop/core/storage/storage_service.dart';
import 'package:balloonpop/features/rewards/domain/player_profile.dart';
import 'package:balloonpop/features/splash/presentation/splash_screen.dart';
import 'package:balloonpop/features/home/presentation/home_screen.dart';

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

  testWidgets('SplashScreen renders branding, tagline and handles tap-to-skip',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(FakeStorageService()),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    // Initial render
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('✨ Pop, Play & Learn! ✨'), findsOneWidget);
    expect(find.text('Tap anywhere to start'), findsOneWidget);

    // Tap to skip
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // Verify navigates to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
