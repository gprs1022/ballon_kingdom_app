import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/monetization/ad_service.dart';
import 'core/audio/sound_manager.dart';
import 'core/constants/game_constants.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI orientation and overlay styles (supports portrait & landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize offline storage & audio
  await StorageService.instance.initialize();
  await SoundManager.instance.initialize();

  runApp(const ProviderScope(child: BalloonKingdomApp()));
}

class BalloonKingdomApp extends StatefulWidget {
  const BalloonKingdomApp({super.key});

  @override
  State<BalloonKingdomApp> createState() => _BalloonKingdomAppState();
}

class _BalloonKingdomAppState extends State<BalloonKingdomApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AdMobService.instance.initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.kidTheme,
      home: const SplashScreen(),
    );
  }
}
