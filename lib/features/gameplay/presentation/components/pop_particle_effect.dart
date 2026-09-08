import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../domain/models/balloon_type.dart';

class PopParticleEffect {
  static final math.Random _random = math.Random();

  static ParticleSystemComponent create({
    required Vector2 position,
    required Color color,
    required BalloonType balloonType,
  }) {
    if (balloonType == BalloonType.bomb) {
      return _createSoftCloudPuff(position);
    }
    return _createConfettiBurst(position, color);
  }

  static ParticleSystemComponent _createConfettiBurst(Vector2 position, Color color) {
    const int count = 22;

    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: 0.6,
        generator: (i) {
          final double angle = _random.nextDouble() * math.pi * 2;
          final double speed = 90.0 + _random.nextDouble() * 160.0;
          final Vector2 velocity = Vector2(math.cos(angle), math.sin(angle)) * speed;
          final Color particleColor = i.isEven ? color : Colors.amber;

          return AcceleratedParticle(
            acceleration: Vector2(0, 220), // Gentle gravity
            speed: velocity,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final double progress = particle.progress;
                final double opacity = (1.0 - progress).clamp(0.0, 1.0);
                final double size = 5.0 * (1.0 - progress * 0.4);

                final paint = Paint()
                  ..color = particleColor.withAlpha((opacity * 255).toInt())
                  ..style = PaintingStyle.fill;

                if (i % 3 == 0) {
                  // Confetti rectangle
                  canvas.drawRect(
                    Rect.fromCenter(center: Offset.zero, width: size * 1.5, height: size),
                    paint,
                  );
                } else {
                  // Star spark circle
                  canvas.drawCircle(Offset.zero, size * 0.7, paint);
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Soft non-violent puff for bomb balloons
  static ParticleSystemComponent _createSoftCloudPuff(Vector2 position) {
    const int count = 12;

    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: 0.7,
        generator: (i) {
          final double angle = _random.nextDouble() * math.pi * 2;
          final double speed = 35.0 + _random.nextDouble() * 45.0;
          final Vector2 velocity = Vector2(math.cos(angle), math.sin(angle)) * speed;

          return AcceleratedParticle(
            speed: velocity,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final double progress = particle.progress;
                final double opacity = ((1.0 - progress) * 0.7).clamp(0.0, 1.0);
                final double radius = 8.0 + progress * 16.0; // Gently expanding cloud puff

                final paint = Paint()
                  ..color = Colors.blueGrey.shade100.withAlpha((opacity * 255).toInt())
                  ..style = PaintingStyle.fill;

                canvas.drawCircle(Offset.zero, radius, paint);
              },
            ),
          );
        },
      ),
    );
  }
}
