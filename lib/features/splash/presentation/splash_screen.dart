import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/presentation/home_screen.dart';

/// Animated Splash Screen providing a warm, playful entrance into Balloon Kingdom.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Play friendly welcoming chime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.playRewardSound();
    });

    // Auto-advance to HomeScreen after 2.4 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2400), _navigateToHome);
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToHome, // Tap to skip
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4FC3F7), // Sky Cyan
                Color(0xFF81D4FA),
                Color(0xFFE1F5FE), // Soft Cloud White
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating ambient background balloons
              ...List.generate(6, (index) {
                final randomOffsets = [
                  const Offset(0.12, 0.18),
                  const Offset(0.85, 0.22),
                  const Offset(0.15, 0.72),
                  const Offset(0.82, 0.68),
                  const Offset(0.28, 0.40),
                  const Offset(0.72, 0.42),
                ];
                final colors = [
                  AppColors.coralRed,
                  AppColors.sunnyGold,
                  AppColors.candyPink,
                  AppColors.playfulViolet,
                  AppColors.vibrantGreen,
                  AppColors.primaryBlue,
                ];
                final sizes = [54.0, 68.0, 48.0, 62.0, 40.0, 44.0];
                final pos = randomOffsets[index % randomOffsets.length];

                return Positioned(
                  left: pos.dx * size.width,
                  top: pos.dy * size.height,
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final wave = math.sin(_floatController.value * math.pi * 2 + index);
                      return Transform.translate(
                        offset: Offset(0, wave * 12),
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.circle,
                      size: sizes[index % sizes.length],
                      color: colors[index % colors.length].withValues(alpha: 0.35),
                    ),
                  ),
                );
              }),

              // Gentle cloud at bottom
              Positioned(
                bottom: -30,
                left: -20,
                right: -20,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.elliptical(300, 80),
                    ),
                  ),
                ),
              ),

              // Central Brand Identity & Animated Logo
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Splash Logo Graphic
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final floatOffset =
                              math.sin(_floatController.value * math.pi * 2) * 8;
                          return Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/splash/splash_logo.png',
                          width: math.min(size.width * 0.72, 320),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback in case asset loading delays
                            return const Icon(
                              Icons.bubble_chart_rounded,
                              size: 140,
                              color: AppColors.sunnyGold,
                            );
                          },
                        ),
                      )
                          .animate()
                          .scale(
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                            begin: const Offset(0.3, 0.3),
                            end: const Offset(1.0, 1.0),
                          )
                          .fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Joyful Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '✨ Pop, Play & Learn! ✨',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E88E5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                          .animate(delay: 350.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: 32),

                      // Loading indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sunnyGold,
                            ),
                          )
                              .animate(
                                delay: (index * 150).ms,
                                onPlay: (c) => c.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(0.7, 0.7),
                                end: const Offset(1.3, 1.3),
                                duration: 500.ms,
                              );
                        }),
                      ).animate(delay: 500.ms).fadeIn(),
                    ],
                  ),
                ),
              ),

              // Tap hint at the bottom
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Tap anywhere to start',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF455A64).withValues(alpha: 0.7),
                    ),
                  ),
                ).animate(delay: 1000.ms).fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
