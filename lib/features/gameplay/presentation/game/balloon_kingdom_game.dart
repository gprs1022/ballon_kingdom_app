import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
  final VoidCallback? onHeartGrantedCallback;
  final void Function(int seconds)? onTimeBonusAddedCallback;

  LevelConfig? levelConfig;
  WorldConfig? worldConfig;
  LearningCategory? learningCategory;
  ChallengeMission? challengeMission;
  
  late BalloonObjectPool _balloonPool;
  final math.Random _random = math.Random();
  
  double _spawnTimer = 0.0;
  double _freezeTimer = 0.0;
  bool isFrozen = false;
  bool isGamePaused = false;
  final bool isHighContrast;
  final bool isColorblindSafe;

  BalloonKingdomGame({
    this.onBalloonPoppedDetailed,
    this.onLearningItemPoppedCallback,
    this.onBombHitCallback,
    this.onHeartGrantedCallback,
    this.onTimeBonusAddedCallback,
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
    } else if (challengeMission != null) {
      final roll = _random.nextDouble();
      if (challengeMission!.targetBalloonType != null && roll < 0.28) {
        type = challengeMission!.targetBalloonType!;
      } else if (roll < 0.10) {
        type = BalloonType.bomb;
      } else if (roll < 0.18) {
        type = BalloonType.time;
      } else if (roll < 0.24) {
        type = BalloonType.heart;
      } else if (roll < 0.30) {
        type = BalloonType.rainbow;
      } else if (roll < 0.36) {
        type = BalloonType.frozen;
      } else if (roll < 0.42) {
        type = BalloonType.rocket;
      } else if (roll < 0.48) {
        type = BalloonType.golden;
      }
    } else if (levelConfig != null && levelConfig!.allowedTypes.isNotEmpty) {
      final allowed = levelConfig!.allowedTypes;
      if (allowed.length > 1 && _random.nextDouble() < 0.35) {
        type = allowed[_random.nextInt(allowed.length)];
      } else {
        type = BalloonType.normal;
      }
    } else {
      final roll = _random.nextDouble();
      if (roll < 0.08) {
        type = BalloonType.golden;
      } else if (roll < 0.14) {
        type = BalloonType.rainbow;
      } else if (roll < 0.20) {
        type = BalloonType.gift;
      } else if (roll < 0.25) {
        type = BalloonType.rocket;
      } else if (roll < 0.30) {
        type = BalloonType.frozen;
      } else if (roll < 0.35) {
        type = BalloonType.time;
      } else if (roll < 0.40) {
        type = BalloonType.heart;
      } else if (roll < 0.45) {
        type = BalloonType.magic;
      } else if (roll < 0.50) {
        type = BalloonType.bomb;
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
      onPopCallback: _handleBalloonPop,
    );

    if (isFrozen) {
      balloon.setSlowMotion(true);
    }
  }

  void _handleBalloonPop(BalloonComponent balloon, Vector2 popPosition) {
    final behavior = balloon.type.behavior;

    if (balloon.learningItem != null) {
      VoiceService.instance.speakItem(balloon.learningItem!);
    } else {
      SoundManager.instance.playPopSound();
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
      scoreText = 'Puff! -1 ❤️';
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
      textColor: balloon.type == BalloonType.bomb ? Colors.white70 : AppColors.sunnyGold,
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

  void resetGame({LevelConfig? newConfig, ChallengeMission? newMission, WorldConfig? newWorld}) {
    if (newConfig != null) levelConfig = newConfig;
    if (newMission != null) challengeMission = newMission;
    if (newWorld != null) worldConfig = newWorld;
    isFrozen = false;
    _freezeTimer = 0.0;
    _balloonPool.recycleAll();
    _spawnTimer = 0.0;
  }
}
