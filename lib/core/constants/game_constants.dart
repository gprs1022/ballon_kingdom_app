class GameConstants {
  static const String appTitle = 'Balloon Kingdom';
  
  // Physics & Balloon specs
  static const double minTouchTarget = 64.0; // Meets accessibility requirement (64dp+)
  static const double baseBalloonWidth = 72.0;
  static const double baseBalloonHeight = 96.0;
  static const double minBalloonSpeed = 135.0;
  static const double maxBalloonSpeed = 220.0;
  static const double balloonPoolCapacity = 30;
  static const double maxOnscreenBalloons = 14;
  
  // Animation timings
  static const double wobbleFrequency = 3.2;
  static const double wobbleAmplitude = 0.08; // Radian tilt
  static const double popAnimationDuration = 0.25;

  // Storage Box Keys
  static const String playerBoxKey = 'player_profile_box';
  static const String settingsBoxKey = 'settings_box';
}
