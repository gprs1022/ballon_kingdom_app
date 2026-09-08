import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../learning/domain/models/learning_item.dart';
import '../../domain/models/balloon_type.dart';

class BalloonComponent extends PositionComponent with TapCallbacks, HasGameReference {
  BalloonType type = BalloonType.normal;
  Color balloonColor = AppColors.primaryBlue;
  LearningItem? learningItem;
  
  double baseFloatSpeed = 100.0;
  double floatSpeedMultiplier = 1.0;
  double horizontalDrift = 0.0;
  double wobblePhase = 0.0;
  double wobbleSpeed = GameConstants.wobbleFrequency;
  
  bool isPopping = false;
  bool isInUse = false;
  bool isRocketLaunching = false;
  bool isHighContrast = false;

  void Function(BalloonComponent balloon, Vector2 tapPosition)? onPopped;

  late CircleHitbox _hitbox;

  BalloonComponent()
      : super(
          size: Vector2(GameConstants.baseBalloonWidth, GameConstants.baseBalloonHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _hitbox = CircleHitbox(
      radius: size.x * 0.48,
      position: Vector2(size.x * 0.5, size.y * 0.45),
      anchor: Anchor.center,
    );
    add(_hitbox);
  }

  void spawn({
    required Vector2 startPosition,
    required BalloonType balloonType,
    required Color color,
    required double speed,
    required double drift,
    required void Function(BalloonComponent, Vector2) onPopCallback,
    LearningItem? educationalItem,
    bool isHighContrastMode = false,
  }) {
    position = startPosition;
    type = balloonType;
    balloonColor = color;
    baseFloatSpeed = speed;
    floatSpeedMultiplier = 1.0;
    horizontalDrift = drift;
    onPopped = onPopCallback;
    learningItem = educationalItem;
    isHighContrast = isHighContrastMode;
    wobblePhase = math.Random().nextDouble() * math.pi * 2;
    wobbleSpeed = GameConstants.wobbleFrequency + (math.Random().nextDouble() * 0.8 - 0.4);
    isPopping = false;
    isInUse = true;
    isRocketLaunching = false;
    scale = Vector2.all(1.0);
    angle = 0.0;
  }

  void setSlowMotion(bool slow) {
    floatSpeedMultiplier = slow ? 0.38 : 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isInUse || isPopping) return;

    if (isRocketLaunching) {
      // Rocket rapid ascent
      position.y -= 580.0 * dt;
      scale = Vector2(0.9, 1.2);
      if (position.y < -size.y) {
        pop();
      }
      return;
    }

    // Standard upward floating with slow-motion multiplier and wind drift
    final effectiveSpeed = baseFloatSpeed * floatSpeedMultiplier;
    position.y -= effectiveSpeed * dt;
    position.x += horizontalDrift * dt;

    // Screen edge bouncing
    final gameWidth = game.size.x;
    final halfWidth = size.x * 0.5;
    if (position.x - halfWidth <= 0) {
      position.x = halfWidth;
      horizontalDrift = horizontalDrift.abs();
    } else if (position.x + halfWidth >= gameWidth) {
      position.x = gameWidth - halfWidth;
      horizontalDrift = -horizontalDrift.abs();
    }

    // Idle animation: wobble & breathing scale pulse
    wobblePhase += wobbleSpeed * dt;
    angle = math.sin(wobblePhase) * GameConstants.wobbleAmplitude;
    final scalePulse = 1.0 + (math.cos(wobblePhase * 0.8) * 0.035);
    scale = Vector2.all(scalePulse);

    // If drifted far offscreen top, recycle back to pool
    if (position.y < -size.y * 1.5) {
      recycle();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isInUse || isPopping) return;

    if (type == BalloonType.rocket && !isRocketLaunching) {
      // Trigger rocket launch!
      isRocketLaunching = true;
      event.handled = true;
      return;
    }

    pop();
    event.handled = true;
  }

  void pop() {
    if (isPopping) return;
    isPopping = true;
    onPopped?.call(this, position.clone());
    recycle();
  }

  void recycle() {
    isInUse = false;
    learningItem = null;
    isRocketLaunching = false;
    floatSpeedMultiplier = 1.0;
    position = Vector2(-200, -200);
  }

  @override
  void render(Canvas canvas) {
    if (!isInUse) return;

    final w = size.x;
    final h = size.y;
    final bodyHeight = h * 0.78;
    final centerX = w * 0.5;
    final centerY = bodyHeight * 0.5;

    // 1. Drop shadow for depth
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 3, centerY + 5),
        width: w * 0.86,
        height: bodyHeight * 0.94,
      ),
      shadowPaint,
    );

    // 2. Dangling string
    final stringPaint = Paint()
      ..color = const Color(0x99424242)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final stringPath = Path();
    stringPath.moveTo(centerX, bodyHeight + 6);
    final stringSway = math.sin(wobblePhase) * 6;
    stringPath.quadraticBezierTo(
      centerX + stringSway,
      bodyHeight + (h - bodyHeight) * 0.5,
      centerX - stringSway * 0.5,
      h,
    );
    canvas.drawPath(stringPath, stringPaint);

    // 3. Rocket Thruster Flame or Knot
    if (isRocketLaunching) {
      final flamePaint = Paint()..color = const Color(0xFFFF6D00);
      canvas.drawCircle(Offset(centerX, bodyHeight + 12), 10, flamePaint);
      canvas.drawCircle(Offset(centerX, bodyHeight + 18), 6, Paint()..color = Colors.yellow);
    } else {
      final knotPaint = Paint()
        ..color = balloonColor.withAlpha(240)
        ..style = PaintingStyle.fill;
      final knotPath = Path();
      knotPath.moveTo(centerX - 6, bodyHeight + 6);
      knotPath.lineTo(centerX + 6, bodyHeight + 6);
      knotPath.lineTo(centerX, bodyHeight);
      knotPath.close();
      canvas.drawPath(knotPath, knotPaint);
    }

    // 4. 3D Volumetric Balloon Body
    final bodyRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: w * 0.9,
      height: bodyHeight,
    );

    final Gradient bodyGradient = _getGradientForType(bodyRect);
    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(bodyRect)
      ..style = PaintingStyle.fill;
    canvas.drawOval(bodyRect, bodyPaint);

    // 5. Specular Glossy Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(150)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(centerX - w * 0.22, centerY - bodyHeight * 0.22);
    canvas.rotate(-math.pi / 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.16,
        height: bodyHeight * 0.28,
      ),
      highlightPaint,
    );
    canvas.restore();

    // High Contrast Accessibility Outline
    if (isHighContrast) {
      final outlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawOval(bodyRect, outlinePaint);
    }

    // 6. Educational Symbol / Type Badges
    if (learningItem != null) {
      _renderLearningBadge(canvas, centerX, centerY);
    } else {
      _renderSpecialTypeBadge(canvas, centerX, centerY);
    }
  }

  Gradient _getGradientForType(Rect rect) {
    if (type == BalloonType.rainbow) {
      return const SweepGradient(
        colors: [
          Color(0xFFFF3366),
          Color(0xFFFFD600),
          Color(0xFF00E676),
          Color(0xFF00B0FF),
          Color(0xFF7C4DFF),
          Color(0xFFFF3366),
        ],
      );
    } else if (type == BalloonType.golden) {
      return const RadialGradient(
        center: Alignment(-0.3, -0.35),
        radius: 0.9,
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFF8F00)],
      );
    } else if (type == BalloonType.frozen) {
      return const RadialGradient(
        center: Alignment(-0.3, -0.35),
        radius: 0.9,
        colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA), Color(0xFF00838F)],
      );
    }

    return RadialGradient(
      center: const Alignment(-0.3, -0.35),
      radius: 0.9,
      colors: [
        Color.lerp(balloonColor, Colors.white, 0.45)!,
        balloonColor,
        Color.lerp(balloonColor, Colors.black, 0.25)!,
      ],
      stops: const [0.0, 0.65, 1.0],
    );
  }

  void _renderLearningBadge(Canvas canvas, double cx, double cy) {
    final badgePaint = Paint()
      ..color = Colors.white.withAlpha(245)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 19, badgePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: learningItem!.displaySymbol,
        style: GoogleFonts.fredoka(
          fontSize: learningItem!.displaySymbol.length > 2 ? 14 : 22,
          fontWeight: FontWeight.w900,
          color: learningItem!.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  void _renderSpecialTypeBadge(Canvas canvas, double cx, double cy) {
    if (type == BalloonType.normal) return;

    final badgePaint = Paint()
      ..color = Colors.white.withAlpha(220)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 16, badgePaint);

    final iconColor = type.behavior.primaryColor;
    final iconPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    switch (type) {
      case BalloonType.golden:
      case BalloonType.magic:
        _drawStar(canvas, cx, cy, 10, 4.5, iconPaint);
        break;
      case BalloonType.heart:
        _drawHeart(canvas, cx, cy, iconPaint);
        break;
      case BalloonType.bomb:
        // Soft cloud puff icon (strictly non-violent)
        canvas.drawCircle(Offset(cx - 3, cy), 5, iconPaint);
        canvas.drawCircle(Offset(cx + 3, cy), 5, iconPaint);
        canvas.drawCircle(Offset(cx, cy - 3), 6, iconPaint);
        break;
      case BalloonType.rocket:
        _drawRocketIcon(canvas, cx, cy, iconPaint);
        break;
      case BalloonType.time:
        _drawClockIcon(canvas, cx, cy, iconPaint);
        break;
      case BalloonType.frozen:
        _drawSnowflakeIcon(canvas, cx, cy, iconPaint);
        break;
      case BalloonType.gift:
        _drawGiftIcon(canvas, cx, cy, iconPaint);
        break;
      case BalloonType.rainbow:
        _drawRainbowIcon(canvas, cx, cy);
        break;
      default:
        canvas.drawCircle(Offset(cx, cy), 7, iconPaint);
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double rOuter, double rInner, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final double r = i.isEven ? rOuter : rInner;
      final double a = (i * math.pi / 5) - math.pi / 2;
      final double px = cx + r * math.cos(a);
      final double py = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double cx, double cy, Paint paint) {
    final path = Path();
    path.moveTo(cx, cy + 6);
    path.cubicTo(cx - 10, cy - 6, cx - 12, cy - 12, cx - 6, cy - 12);
    path.cubicTo(cx - 2, cy - 12, cx, cy - 7, cx, cy - 7);
    path.cubicTo(cx, cy - 7, cx + 2, cy - 12, cx + 6, cy - 12);
    path.cubicTo(cx + 12, cy - 12, cx + 10, cy - 6, cx, cy + 6);
    canvas.drawPath(path, paint);
  }

  void _drawRocketIcon(Canvas canvas, double cx, double cy, Paint paint) {
    final path = Path();
    path.moveTo(cx, cy - 8);
    path.lineTo(cx + 5, cy + 4);
    path.lineTo(cx - 5, cy + 4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawClockIcon(Canvas canvas, double cx, double cy, Paint paint) {
    final outline = Paint()
      ..color = paint.color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 8, outline);
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 5), outline);
    canvas.drawLine(Offset(cx, cy), Offset(cx + 4, cy), outline);
  }

  void _drawSnowflakeIcon(Canvas canvas, double cx, double cy, Paint paint) {
    final stroke = Paint()
      ..color = paint.color
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 7, cy), Offset(cx + 7, cy), stroke);
    canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 7), stroke);
    canvas.drawLine(Offset(cx - 5, cy - 5), Offset(cx + 5, cy + 5), stroke);
    canvas.drawLine(Offset(cx + 5, cy - 5), Offset(cx - 5, cy + 5), stroke);
  }

  void _drawGiftIcon(Canvas canvas, double cx, double cy, Paint paint) {
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 1), width: 12, height: 10), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 5), width: 14, height: 3), paint);
  }

  void _drawRainbowIcon(Canvas canvas, double cx, double cy) {
    final colors = [Colors.red, Colors.yellow, Colors.blue];
    for (int i = 0; i < colors.length; i++) {
      final p = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy + 4), radius: 10.0 - (i * 2.5)),
        math.pi,
        math.pi,
        false,
        p,
      );
    }
  }
}
