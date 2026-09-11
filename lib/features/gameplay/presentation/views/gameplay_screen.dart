import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/widgets/bouncy_button.dart';
import '../../../learning/domain/models/learning_item.dart';
import '../../../learning/presentation/components/learning_pop_overlay.dart';
import '../../../worlds/domain/world_config.dart';
import '../../domain/models/challenge_mission.dart';
import '../../domain/models/level_config.dart';
import '../game/balloon_kingdom_game.dart';
import '../providers/gameplay_notifier.dart';
import 'challenge_complete_dialog.dart';
import 'game_hud_overlay.dart';
import 'level_complete_dialog.dart';
import 'wrong_balloon_dialog.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final LevelConfig? levelConfig;
  final WorldConfig? worldConfig;
  final LearningCategory? learningCategory;
  final ChallengeMission? challengeMission;

  const GameplayScreen({
    super.key,
    this.levelConfig,
    this.worldConfig,
    this.learningCategory,
    this.challengeMission,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with WidgetsBindingObserver {
  late BalloonKingdomGame _game;
  bool _dialogShown = false;
  LearningItem? _activeLearningPop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SoundManager.instance.startBgm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gameplayNotifierProvider.notifier)
          .initSession(
            levelConfig: widget.levelConfig,
            challengeMission: widget.challengeMission,
          );
    });

    final profile = ref.read(playerProfileProvider);

    _game = BalloonKingdomGame(
      levelConfig: widget.levelConfig,
      worldConfig: widget.worldConfig,
      learningCategory: widget.learningCategory,
      challengeMission: widget.challengeMission,
      isHighContrast: profile.isHighContrastMode,
      isColorblindSafe: profile.isColorblindSafeMode,
      onBalloonPoppedDetailed: (points, coins, type, color) {
        ref
            .read(gameplayNotifierProvider.notifier)
            .onBalloonPoppedDetailed(points, coins, type, color);
      },
      onLearningItemPoppedCallback: (item) {
        setState(() {
          _activeLearningPop = item;
        });
      },
      onBombHitCallback: () {
        ref.read(gameplayNotifierProvider.notifier).hitBomb();
      },
      onAvoidBalloonPoppedCallback: () {
        ref.read(gameplayNotifierProvider.notifier).hitAvoidBalloon();
      },
      onHeartGrantedCallback: () {
        ref.read(gameplayNotifierProvider.notifier).grantHeart();
      },
      onTimeBonusAddedCallback: (secs) {
        ref.read(gameplayNotifierProvider.notifier).addTimeBonus(secs);
      },
      onAdBalloonTappedCallback: () async {
        if (!mounted) return;
        SoundManager.instance.pauseBgm();
        final shown = await ref.read(adServiceProvider).showRewardedVideo(
          context,
          placement: 'ad_balloon_screen_blast',
          onReward: () {
            _game.triggerScreenBlastReward();
          },
        );
        SoundManager.instance.resumeBgm();
        if (!shown && mounted) {
          _game.resumeGame();
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SoundManager.instance.stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Device sleep mode / screen turned off / app minimized: pause gameplay & BGM
      _game.pauseGame();
      SoundManager.instance.pauseBgm();
      if (mounted && !_dialogShown) {
        _showPauseDialog();
      }
    }
  }

  void _onWrongBalloonPopped(GameplayState state) {
    if (_dialogShown) return;
    _dialogShown = true;
    _game.pauseGame();
    SoundManager.instance.pauseBgm();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return WrongBalloonDialog(
          score: state.score,
          poppedCount: state.poppedCount,
          levelIndex: widget.levelConfig?.index,
          onRevive: () {
            Navigator.of(context).pop();
            _dialogShown = false;
            ref.read(gameplayNotifierProvider.notifier).reviveFromWrongBalloon();
            _game.reviveGame();
            SoundManager.instance.resumeBgm();
          },
          onReplay: () {
            Navigator.of(context).pop();
            _dialogShown = false;
            ref.read(gameplayNotifierProvider.notifier).resetSession();
            _game.resetGame(
              newConfig: widget.levelConfig,
              newMission: widget.challengeMission,
              newWorld: widget.worldConfig,
            );
            _game.resumeGame();
            SoundManager.instance.resumeBgm();
          },
          onExit: () {
            SoundManager.instance.stopBgm();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _onLevelCompleted(GameplayState state) {
    if (_dialogShown) return;
    _dialogShown = true;
    _game.pauseGame();
    SoundManager.instance.pauseBgm();

    final result = state.completionResult;
    if (result == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return LevelCompleteDialog(
          result: result,
          score: state.score,
          targetScore: widget.levelConfig?.targetScore ?? 20,
          onNextLevel: () {
            Navigator.of(context).pop();
            final nextIndex = (widget.levelConfig?.index ?? 1) + 1;
            final currentWorld = widget.worldConfig ?? WorldConfig.sunnySky();
            if (nextIndex <= currentWorld.levels.length) {
              final nextConfig = currentWorld.levels[nextIndex - 1];
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameplayScreen(
                    levelConfig: nextConfig,
                    worldConfig: currentWorld,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          onReplay: () {
            Navigator.of(context).pop();
            _dialogShown = false;
            ref.read(gameplayNotifierProvider.notifier).resetSession();
            _game.resetGame(
              newConfig: widget.levelConfig,
              newWorld: widget.worldConfig,
            );
            _game.resumeGame();
          },
          onExit: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _onChallengeFinished(GameplayState state) {
    if (_dialogShown) return;
    _dialogShown = true;
    _game.pauseGame();
    SoundManager.instance.pauseBgm();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return ChallengeCompleteDialog(
          isVictory: state.isMissionCompleted,
          medal: state.medalEarned,
          timeRemaining: state.timeRemaining,
          score: state.score,
          onReplay: () {
            Navigator.of(context).pop();
            _dialogShown = false;
            ref.read(gameplayNotifierProvider.notifier).resetSession();
            _game.resetGame(newMission: widget.challengeMission);
            _game.resumeGame();
          },
          onExit: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showPauseDialog() {
    _game.pauseGame();
    SoundManager.instance.pauseBgm();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Paused',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                BouncyButton(
                  minWidth: 200,
                  backgroundColor: AppColors.vibrantGreen,
                  onTap: () {
                    Navigator.of(context).pop();
                    _game.resumeGame();
                    SoundManager.instance.resumeBgm();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Resume',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BouncyButton(
                  minWidth: 200,
                  backgroundColor: AppColors.sunnyGold,
                  onTap: () {
                    Navigator.of(context).pop();
                    ref.read(gameplayNotifierProvider.notifier).resetSession();
                    _game.resetGame(
                      newConfig: widget.levelConfig,
                      newMission: widget.challengeMission,
                      newWorld: widget.worldConfig,
                    );
                    _game.resumeGame();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textDark,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Restart',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BouncyButton(
                  minWidth: 200,
                  backgroundColor: AppColors.coralRed,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameplayState>(gameplayNotifierProvider, (previous, next) {
      if (next.isLevelCompleted && !_dialogShown) {
        _onLevelCompleted(next);
      } else if (next.isWrongBalloonGameOver && !_dialogShown) {
        _onWrongBalloonPopped(next);
      } else if ((next.isMissionCompleted || next.isGameOver) &&
          !_dialogShown) {
        _onChallengeFinished(next);
      }
    });

    final bgColors =
        widget.worldConfig?.themeColors ??
        const [Color(0xFF42A5F5), Color(0xFF90CAF9), Color(0xFFE3F2FD)];
    final decorType = widget.worldConfig?.decorativeType ?? 'cloud';

    return Scaffold(
      body: Stack(
        children: [
          // 1. World Theme Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgColors,
              ),
            ),
          ),

          // 2. Ambient Floating World Decorations
          Positioned(
            top: 60,
            left: 20,
            child: _buildAmbientIcon(decorType, 80)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 20, duration: 4.seconds),
          ),
          Positioned(
            top: 140,
            right: 30,
            child: _buildAmbientIcon(decorType, 100)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: -25, duration: 5.seconds),
          ),
          Positioned(
            bottom: 40,
            left: 50,
            child: _buildAmbientIcon(decorType, 70)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: 15, duration: 6.seconds),
          ),

          // 3. Flame Game Canvas
          Positioned.fill(child: GameWidget<BalloonKingdomGame>(game: _game)),

          // 4. Game HUD Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GameHudOverlay(onPauseTap: _showPauseDialog),
          ),

          // 5. On-Pop Educational Flashcard Overlay
          if (_activeLearningPop != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: LearningPopOverlay(
                  item: _activeLearningPop!,
                  onDismiss: () {
                    if (mounted) {
                      setState(() => _activeLearningPop = null);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmbientIcon(String type, double size) {
    IconData icon;
    switch (type) {
      case 'bubble':
        icon = Icons.bubble_chart_rounded;
        break;
      case 'star':
        icon = Icons.auto_awesome_rounded;
        break;
      case 'leaf':
        icon = Icons.eco_rounded;
        break;
      case 'candy':
        icon = Icons.cake_rounded;
        break;
      case 'snowflake':
        icon = Icons.ac_unit_rounded;
        break;
      default:
        icon = Icons.cloud_rounded;
    }
    return Icon(icon, size: size, color: Colors.white.withAlpha(80));
  }
}
