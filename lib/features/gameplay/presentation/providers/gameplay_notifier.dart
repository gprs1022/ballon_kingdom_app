import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../rewards/domain/reward_service.dart';
import '../../domain/models/balloon_type.dart';
import '../../domain/models/challenge_mission.dart';
import '../../domain/models/level_config.dart';

class GameplayState {
  final int score;
  final int poppedCount;
  final int coinsEarned;
  final bool isPaused;
  final LevelConfig? levelConfig;
  final bool isLevelCompleted;
  final LevelCompleteResult? completionResult;

  // Challenge Mode fields
  final ChallengeMission? challengeMission;
  final int lives;
  final int timeRemaining;
  final int missionProgress;
  final bool isMissionCompleted;
  final bool isGameOver;
  final bool isWrongBalloonGameOver;
  final MedalType medalEarned;

  const GameplayState({
    this.score = 0,
    this.poppedCount = 0,
    this.coinsEarned = 0,
    this.isPaused = false,
    this.levelConfig,
    this.isLevelCompleted = false,
    this.completionResult,
    this.challengeMission,
    this.lives = 3,
    this.timeRemaining = 30,
    this.missionProgress = 0,
    this.isMissionCompleted = false,
    this.isGameOver = false,
    this.isWrongBalloonGameOver = false,
    this.medalEarned = MedalType.none,
  });

  bool get isLevelMode => levelConfig != null;
  bool get isChallengeMode => challengeMission != null;

  double get progressFraction {
    if (isLevelMode && levelConfig!.targetScore > 0) {
      return (score / levelConfig!.targetScore).clamp(0.0, 1.0);
    }
    if (isChallengeMode && challengeMission!.targetCount > 0) {
      return (missionProgress / challengeMission!.targetCount).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  GameplayState copyWith({
    int? score,
    int? poppedCount,
    int? coinsEarned,
    bool? isPaused,
    LevelConfig? levelConfig,
    bool? isLevelCompleted,
    LevelCompleteResult? completionResult,
    ChallengeMission? challengeMission,
    int? lives,
    int? timeRemaining,
    int? missionProgress,
    bool? isMissionCompleted,
    bool? isGameOver,
    bool? isWrongBalloonGameOver,
    MedalType? medalEarned,
  }) {
    return GameplayState(
      score: score ?? this.score,
      poppedCount: poppedCount ?? this.poppedCount,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      isPaused: isPaused ?? this.isPaused,
      levelConfig: levelConfig ?? this.levelConfig,
      isLevelCompleted: isLevelCompleted ?? this.isLevelCompleted,
      completionResult: completionResult ?? this.completionResult,
      challengeMission: challengeMission ?? this.challengeMission,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      missionProgress: missionProgress ?? this.missionProgress,
      isMissionCompleted: isMissionCompleted ?? this.isMissionCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      isWrongBalloonGameOver:
          isWrongBalloonGameOver ?? this.isWrongBalloonGameOver,
      medalEarned: medalEarned ?? this.medalEarned,
    );
  }
}

class GameplayNotifier extends StateNotifier<GameplayState> {
  final RewardService _rewardService;
  Timer? _countdownTimer;

  GameplayNotifier(this._rewardService) : super(const GameplayState());

  void initSession({LevelConfig? levelConfig, ChallengeMission? challengeMission}) {
    _countdownTimer?.cancel();

    if (challengeMission != null) {
      state = GameplayState(
        challengeMission: challengeMission,
        timeRemaining: challengeMission.timeLimitSeconds,
        lives: 3,
        missionProgress: 0,
      );
      _startTimer();
    } else {
      state = GameplayState(levelConfig: levelConfig);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused || state.isMissionCompleted || state.isGameOver) return;

      if (state.timeRemaining > 1) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time Up -> Game Over
        state = state.copyWith(timeRemaining: 0, isGameOver: true);
        timer.cancel();
      }
    });
  }

  void addTimeBonus(int seconds) {
    if (!state.isChallengeMode || state.isGameOver || state.isMissionCompleted) return;
    state = state.copyWith(timeRemaining: state.timeRemaining + seconds);
  }

  void grantHeart() {
    if (!state.isChallengeMode || state.isGameOver || state.isMissionCompleted) return;
    final updatedLives = (state.lives + 1).clamp(0, 3);
    state = state.copyWith(lives: updatedLives);
  }

  void hitBomb() {
    if (state.isLevelMode) {
      hitAvoidBalloon();
      return;
    }
    if (!state.isChallengeMode || state.isGameOver || state.isMissionCompleted) {
      hitAvoidBalloon();
      return;
    }
    final updatedLives = state.lives - 1;
    if (updatedLives <= 0) {
      state = state.copyWith(lives: 0, isGameOver: true, isWrongBalloonGameOver: true);
      _countdownTimer?.cancel();
    } else {
      state = state.copyWith(lives: updatedLives);
    }
  }

  void hitAvoidBalloon() {
    if (state.isGameOver || state.isMissionCompleted || state.isLevelCompleted) return;
    _countdownTimer?.cancel();
    state = state.copyWith(
      isGameOver: true,
      isWrongBalloonGameOver: true,
      lives: 0,
    );
  }

  void reviveFromWrongBalloon() {
    if (!state.isGameOver) return;
    state = state.copyWith(
      isGameOver: false,
      isWrongBalloonGameOver: false,
      lives: state.isChallengeMode ? 1 : state.lives,
    );
    if (state.isChallengeMode && state.timeRemaining > 0) {
      _startTimer();
    }
  }

  Future<void> onBalloonPopped(int points, int coins) async {
    await onBalloonPoppedDetailed(points, coins, BalloonType.normal, Colors.blue);
  }

  Future<void> onBalloonPoppedDetailed(
    int points,
    int coins,
    BalloonType type,
    Color color,
  ) async {
    if (state.isLevelCompleted || state.isMissionCompleted || state.isGameOver) return;

    final newScore = state.score + points;
    final newPoppedCount = state.poppedCount + 1;
    final newCoins = state.coinsEarned + coins;

    int newMissionProgress = state.missionProgress;
    if (state.isChallengeMode) {
      final mission = state.challengeMission!;
      if (mission.type == MissionType.popCount) {
        newMissionProgress++;
      } else if (mission.type == MissionType.popColor && mission.targetColor != null) {
        if (color.toARGB32() == mission.targetColor!.toARGB32()) {
          newMissionProgress++;
        }
      } else if (mission.type == MissionType.popType && mission.targetBalloonType != null) {
        if (type == mission.targetBalloonType) {
          newMissionProgress++;
        }
      } else if (mission.type == MissionType.targetScore) {
        newMissionProgress = newScore;
      }
    }

    state = state.copyWith(
      score: newScore,
      poppedCount: newPoppedCount,
      coinsEarned: newCoins,
      missionProgress: newMissionProgress,
    );

    // Single source of truth rewards
    await _rewardService.onBalloonPopped(coins: coins, points: points);

    // Level Mode check
    if (state.isLevelMode &&
        newScore >= state.levelConfig!.targetScore &&
        !state.isLevelCompleted) {
      final result = await _rewardService.onLevelCompleted(
        levelConfig: state.levelConfig!,
        finalScore: newScore,
      );
      state = state.copyWith(
        isLevelCompleted: true,
        completionResult: result,
      );
    }

    // Challenge Mode win condition check
    if (state.isChallengeMode &&
        newMissionProgress >= state.challengeMission!.targetCount &&
        !state.isMissionCompleted &&
        !state.isGameOver) {
      _countdownTimer?.cancel();
      final medal = state.challengeMission!.calculateMedal(state.timeRemaining);
      state = state.copyWith(
        isMissionCompleted: true,
        medalEarned: medal,
      );
      // Grant challenge completion bonus
      await _rewardService.onBalloonPopped(coins: 20, points: 25);
    }
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void resetSession() {
    initSession(
      levelConfig: state.levelConfig,
      challengeMission: state.challengeMission,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final gameplayNotifierProvider =
    StateNotifierProvider<GameplayNotifier, GameplayState>((ref) {
  final rewardService = ref.watch(rewardServiceProvider);
  return GameplayNotifier(rewardService);
});
