import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/audio/sound_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../learning/domain/models/learning_item.dart';
import '../../../learning/domain/services/learning_content_provider.dart';
import '../../../learning/domain/services/voice_service.dart';
import '../../../worlds/domain/world_config.dart';
import '../../domain/models/balloon_type.dart';
import '../../domain/models/challenge_mission.dart';
import '../../domain/models/level_config.dart';
import '../../domain/services/balloon_pool.dart';
import '../components/balloon_component.dart';
import '../components/floating_score_component.dart';
import '../components/pop_particle_effect.dart';

class BalloonKingdomGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  final void Function(int points, int coins, BalloonType type, Color color)? onBalloonPoppedDetailed;
  final void Function(LearningItem item)? onLearningItemPoppedCallback;
  final VoidCallback? onBombHitCallback;
  final VoidCallback? onAvoidBalloonPoppedCallback;
  final VoidCallback? onHeartGrantedCallback;
  final void Function(int seconds)? onTimeBonusAddedCallback;
  final VoidCallback? onAdBalloonTappedCallback;

  LevelConfig? levelConfig;
  WorldConfig? worldConfig;
  LearningCategory? learningCategory;
  ChallengeMission? challengeMission;
  
  late BalloonObjectPool _balloonPool;
  final math.Random _random = math.Random();
  
  double _spawnTimer = 0.0;
  double _freezeTimer = 0.0;
  double _adBalloonTimer = 0.0;
  int _comboStreak = 0;
  double _comboTimer = 0.0;
  bool isFrozen = false;
  bool isGamePaused = false;
  final bool isHighContrast;
  final bool isColorblindSafe;

  BalloonKingdomGame({
    this.onBalloonPoppedDetailed,
    this.onLearningItemPoppedCallback,
    this.onBombHitCallback,
    this.onAvoidBalloonPoppedCallback,
    this.onHeartGrantedCallback,
    this.onTimeBonusAddedCallback,
    this.onAdBalloonTappedCallback,
    this.levelConfig,
    this.worldConfig,
    this.learningCategory,
    this.challengeMission,
    this.isHighContrast = false,
    this.isColorblindSafe = false,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  double get currentSpawnInterval =>
      levelConfig?.spawnIntervalSeconds ?? (learningCategory != null ? 1.0 : 0.82);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _balloonPool = BalloonObjectPool(
      parent: this,
      initialCapacity: GameConstants.balloonPoolCapacity.toInt(),
    );
  }

  @override
  void update(double dt) {
    if (isGamePaused) return;
    super.update(dt);

    if (_comboStreak > 0) {
      _comboTimer += dt;
      if (_comboTimer > 1.3) {
        _comboStreak = 0;
      }
    }

    _adBalloonTimer += dt;

    if (isFrozen) {
      _freezeTimer -= dt;
      if (_freezeTimer <= 0) {
        isFrozen = false;
        _balloonPool.setSlowMotionAll(false);
      }
    }

    _spawnTimer += dt;
    if (_spawnTimer >= currentSpawnInterval) {
      _spawnTimer = 0.0;
      if (_balloonPool.activeCount < GameConstants.maxOnscreenBalloons) {
        _spawnBalloon();
      }
    }
  }

  void _spawnBalloon() {
    if (size.x <= 0 || size.y <= 0) return;

    final balloon = _balloonPool.acquire();

    final minX = GameConstants.baseBalloonWidth * 0.6;
    final maxX = size.x - GameConstants.baseBalloonWidth * 0.6;
    final startX = minX + _random.nextDouble() * (maxX - minX);
    final startY = size.y + GameConstants.baseBalloonHeight * 0.6;

    BalloonType type = BalloonType.normal;
    LearningItem? eduItem;

    if (learningCategory != null) {
      eduItem = LearningContentProvider.getRandomItem(learningCategory!);
      type = BalloonType.normal;
    } else if (_adBalloonTimer >= 35.0 && _balloonPool.activeCount >= 2) {
      _adBalloonTimer = 0.0;
      type = BalloonType.adBalloon;
    } else if (levelConfig != null) {
      // Level Mode: Frequency of avoid balloons scales progressively by level
      final lvl = levelConfig!.index;
      final double avoidRate;
      if (lvl <= 1) {
        avoidRate = 0.06; // Level 1 introduction
      } else if (lvl <= 3) {
        avoidRate = 0.10; // Level 2-3
      } else if (lvl <= 6) {
        avoidRate = 0.15; // Level 4-6
      } else if (lvl <= 10) {
        avoidRate = 0.20; // Level 7-10
      } else if (lvl <= 15) {
        avoidRate = 0.25; // Level 11-15
      } else {
        avoidRate = 0.30; // Level 16-20
      }

      if (_random.nextDouble() < avoidRate) {
        type = BalloonType.bomb;
      } else if (levelConfig!.allowedTypes.isNotEmpty) {
        final allowed = levelConfig!.allowedTypes.where((t) => t != BalloonType.bomb).toList();
        if (allowed.isNotEmpty && _random.nextDouble() < 0.35) {
          type = allowed[_random.nextInt(allowed.length)];
        } else {
          type = BalloonType.normal;
        }
      } else {
        type = BalloonType.normal;
      }
    } else if (challengeMission != null) {
      final roll = _random.nextDouble();
      if (challengeMission!.targetBalloonType != null && roll < 0.28) {
        type = challengeMission!.targetBalloonType!;
      } else if (roll < 0.14) {
        type = BalloonType.bomb;
      } else if (roll < 0.22) {
        type = BalloonType.time;
      } else if (roll < 0.28) {
        type = BalloonType.heart;
      } else if (roll < 0.34) {
        type = BalloonType.rainbow;
      } else if (roll < 0.40) {
        type = BalloonType.frozen;
      } else if (roll < 0.46) {
        type = BalloonType.rocket;
      } else if (roll < 0.52) {
        type = BalloonType.golden;
      }
    } else {
      // Normal / Free Play mode: Avoid balloons appear with prominent frequency (15%)
      final roll = _random.nextDouble();
      if (roll < 0.15) {
        type = BalloonType.bomb;
      } else if (roll < 0.23) {
        type = BalloonType.golden;
      } else if (roll < 0.30) {
        type = BalloonType.rainbow;
      } else if (roll < 0.36) {
        type = BalloonType.gift;
      } else if (roll < 0.41) {
        type = BalloonType.rocket;
      } else if (roll < 0.46) {
        type = BalloonType.frozen;
      } else if (roll < 0.51) {
        type = BalloonType.time;
      } else if (roll < 0.56) {
        type = BalloonType.heart;
      } else if (roll < 0.61) {
        type = BalloonType.magic;
      }
    }

    // Balloon Color: Curated per world or colorblind accessible palette
    final Color color;
    final palette = isColorblindSafe
        ? const [
            Color(0xFF0072B2), // Cobalt Blue
            Color(0xFFE69F00), // Amber
            Color(0xFF56B4E9), // Sky Blue
            Color(0xFF009E73), // Bluish Green
            Color(0xFFD55E00), // Vermilion
            Color(0xFFCC79A7), // Reddish Purple
          ]
        : (worldConfig?.balloonPalette ?? AppColors.balloonPalette);

    if (eduItem != null) {
      color = eduItem.color;
    } else if (challengeMission?.targetColor != null && _random.nextDouble() < 0.35) {
      color = challengeMission!.targetColor!;
    } else if (type == BalloonType.adBalloon) {
      color = AppColors.adBalloonPurple;
    } else if (type == BalloonType.bomb) {
      color = AppColors.bombBody;
    } else if (type == BalloonType.golden) {
      color = AppColors.goldAccent;
    } else if (type == BalloonType.frozen) {
      color = const Color(0xFF80DEEA);
    } else if (type == BalloonType.time) {
      color = const Color(0xFF00E676);
    } else if (type == BalloonType.heart) {
      color = const Color(0xFFFF4081);
    } else {
      color = palette[_random.nextInt(palette.length)];
    }

    // Determine if this balloon is an active mission target
    bool isTarget = false;
    if (challengeMission != null) {
      if (challengeMission!.targetBalloonType != null && type == challengeMission!.targetBalloonType) {
        isTarget = true;
      } else if (challengeMission!.targetColor != null && color == challengeMission!.targetColor) {
        isTarget = true;
      }
    }

    final minSpd = levelConfig?.minSpeed ?? (learningCategory != null ? 80.0 : GameConstants.minBalloonSpeed);
    final maxSpd = levelConfig?.maxSpeed ?? (learningCategory != null ? 130.0 : GameConstants.maxBalloonSpeed);
    final speed = minSpd + _random.nextDouble() * (maxSpd - minSpd);
    final drift = (_random.nextDouble() * 32.0 - 16.0);

    balloon.spawn(
      startPosition: Vector2(startX, startY),
      balloonType: type,
      color: color,
      speed: speed,
      drift: drift,
      educationalItem: eduItem,
      isHighContrastMode: isHighContrast,
      isTarget: isTarget,
      onPopCallback: _handleBalloonPop,
    );

    if (isFrozen) {
      balloon.setSlowMotion(true);
    }
  }

  void _handleBalloonPop(BalloonComponent balloon, Vector2 popPosition) {
    final behavior = balloon.type.behavior;

    if (balloon.type == BalloonType.adBalloon) {
      HapticFeedback.mediumImpact();
      SoundManager.instance.playRewardSound();
      final particle = PopParticleEffect.create(
        position: popPosition,
        color: AppColors.adBalloonGold,
        balloonType: BalloonType.golden,
      );
      add(particle);
      add(FloatingScoreComponent(
        position: popPosition,
        text: 'BONUS! 🎬',
        textColor: AppColors.adBalloonGold,
      ));
      pauseGame();
      onAdBalloonTappedCallback?.call();
      return;
    }

    if (balloon.type == BalloonType.bomb) {
      HapticFeedback.heavyImpact();
      SoundManager.instance.playHazardSound();
      _comboStreak = 0;
      final particle = PopParticleEffect.create(
        position: popPosition,
        color: AppColors.coralRed,
        balloonType: BalloonType.bomb,
      );
      add(particle);
      add(FloatingScoreComponent(
        position: popPosition,
        text: 'WRONG BALLOON! 💥',
        textColor: AppColors.coralRed,
      ));
      pauseGame();
      onAvoidBalloonPoppedCallback?.call();
      onBombHitCallback?.call();
      return;
    }

    if (balloon.learningItem != null) {
      VoiceService.instance.speakItem(balloon.learningItem!);
      HapticFeedback.lightImpact();
    } else {
      _comboStreak++;
      _comboTimer = 0.0;
      final scaleIndex = (_comboStreak - 1) % 6;
      SoundManager.instance.playPopSound(scaleDegree: scaleIndex);
      HapticFeedback.lightImpact();
      if (_comboStreak >= 3) {
        add(FloatingScoreComponent(
          position: popPosition - Vector2(0, 26),
          text: '$_comboStreak x STREAK! 🔥',
          textColor: const Color(0xFFFF6D00),
        ));
      }
    }

    final particle = PopParticleEffect.create(
      position: popPosition,
      color: balloon.balloonColor,
      balloonType: balloon.type,
    );
    add(particle);

    String scoreText = '+${behavior.points}';
    if (balloon.learningItem != null) {
      scoreText = balloon.learningItem!.displaySymbol;
    } else if (balloon.type == BalloonType.bomb) {
      scoreText = levelConfig != null ? '-15 pts ⚠️' : 'Puff! -1 ❤️';
    } else if (balloon.type == BalloonType.heart) {
      scoreText = '+1 ❤️';
    } else if (balloon.type == BalloonType.time) {
      scoreText = '+10s ⏱️';
    } else if (balloon.type == BalloonType.frozen) {
      scoreText = 'Freeze! ❄️';
    } else if (balloon.type == BalloonType.rainbow) {
      scoreText = 'Chain Burst! 🌈';
    }

    add(FloatingScoreComponent(
      position: popPosition,
      text: scoreText,
      textColor: balloon.type == BalloonType.bomb ? AppColors.hazardWarning : AppColors.sunnyGold,
    ));

    _executeSpecialBalloonBehavior(balloon.type, popPosition);

    onBalloonPoppedDetailed?.call(behavior.points, behavior.coinReward, balloon.type, balloon.balloonColor);

    if (balloon.learningItem != null) {
      onLearningItemPoppedCallback?.call(balloon.learningItem!);
    }
  }

  void _executeSpecialBalloonBehavior(BalloonType type, Vector2 pos) {
    switch (type) {
      case BalloonType.rainbow:
        final nearby = _balloonPool.getBalloonsInRadius(pos, 140.0);
        for (final b in nearby) {
          b.pop();
        }
        break;

      case BalloonType.frozen:
        isFrozen = true;
        _freezeTimer = 5.0;
        _balloonPool.setSlowMotionAll(true);
        break;

      case BalloonType.time:
        onTimeBonusAddedCallback?.call(10);
        break;

      case BalloonType.heart:
        onHeartGrantedCallback?.call();
        break;

      case BalloonType.bomb:
        onBombHitCallback?.call();
        break;

      case BalloonType.gift:
        add(PopParticleEffect.create(
          position: pos,
          color: AppColors.goldAccent,
          balloonType: BalloonType.golden,
        ));
        break;

      case BalloonType.magic:
        final roll = _random.nextDouble();
        if (roll < 0.5) {
          isFrozen = true;
          _freezeTimer = 4.0;
          _balloonPool.setSlowMotionAll(true);
        } else {
          final nearby = _balloonPool.getBalloonsInRadius(pos, 120.0);
          for (final b in nearby) {
            b.pop();
          }
        }
        break;

      default:
        break;
    }
  }

  void pauseGame() {
    isGamePaused = true;
  }

  void resumeGame() {
    isGamePaused = false;
  }

  void reviveGame() {
    // Clear active avoid/bomb balloons on screen so player resumes in safety
    final bombs = _balloonPool.activeBalloons
        .where((b) => b.type == BalloonType.bomb)
        .toList();
    for (final b in bombs) {
      b.recycle();
    }
    resumeGame();
  }

  void triggerScreenBlastReward() {
    SoundManager.instance.playRewardSound();
    HapticFeedback.heavyImpact();

    // Pop all currently active onscreen balloons with golden celebration bursts
    final active = _balloonPool.activeBalloons.toList();
    int blastCount = 0;
    for (final b in active) {
      if (b.isInUse && !b.isPopping) {
        final pos = b.position.clone();
        final col = b.balloonColor;
        b.pop();
        blastCount++;
        add(PopParticleEffect.create(
          position: pos,
          color: col,
          balloonType: BalloonType.golden,
        ));
      }
    }

    add(FloatingScoreComponent(
      position: Vector2(size.x * 0.5, size.y * 0.38),
      text: '💥 SCREEN BLAST! +25 🪙',
      textColor: AppColors.sunnyGold,
    ));

    // Award bonus points, coins, and an extra heart
    onBalloonPoppedDetailed?.call(25 + blastCount * 2, 25, BalloonType.adBalloon, AppColors.adBalloonGold);
    onHeartGrantedCallback?.call();
    resumeGame();
  }

  void resetGame({LevelConfig? newConfig, ChallengeMission? newMission, WorldConfig? newWorld}) {
    if (newConfig != null) levelConfig = newConfig;
    if (newMission != null) challengeMission = newMission;
    if (newWorld != null) worldConfig = newWorld;
    isFrozen = false;
    _freezeTimer = 0.0;
    _adBalloonTimer = 0.0;
    _comboStreak = 0;
    _balloonPool.recycleAll();
    _spawnTimer = 0.0;
  }
}
