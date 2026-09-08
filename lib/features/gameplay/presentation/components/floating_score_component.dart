import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingScoreComponent extends PositionComponent {
  final String text;
  final Color textColor;
  double _elapsed = 0.0;
  static const double _lifetime = 0.75;
  late final TextPainter _textPainter;

  FloatingScoreComponent({
    required Vector2 position,
    required this.text,
    this.textColor = const Color(0xFFFFD54F),
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textColor,
          shadows: const [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black38,
              offset: Offset(1.5, 1.5),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= 55.0 * dt; // Float upward
    if (_elapsed >= _lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final double opacity = (1.0 - (_elapsed / _lifetime)).clamp(0.0, 1.0);
    final paint = Paint()..color = Colors.white.withAlpha((opacity * 255).toInt());
    canvas.saveLayer(null, paint);
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
    canvas.restore();
  }
}
