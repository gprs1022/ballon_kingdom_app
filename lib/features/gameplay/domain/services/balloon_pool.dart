import 'package:flame/components.dart';
import '../../presentation/components/balloon_component.dart';

class BalloonObjectPool {
  final List<BalloonComponent> _pool = [];
  final Component _parent;

  BalloonObjectPool({required Component parent, int initialCapacity = 25})
      : _parent = parent {
    for (int i = 0; i < initialCapacity; i++) {
      final balloon = BalloonComponent();
      _pool.add(balloon);
      _parent.add(balloon);
      balloon.recycle();
    }
  }

  BalloonComponent acquire() {
    for (final balloon in _pool) {
      if (!balloon.isInUse) {
        return balloon;
      }
    }
    final extraBalloon = BalloonComponent();
    _pool.add(extraBalloon);
    _parent.add(extraBalloon);
    extraBalloon.recycle();
    return extraBalloon;
  }

  List<BalloonComponent> get activeBalloons =>
      _pool.where((b) => b.isInUse && !b.isPopping).toList();

  int get activeCount => activeBalloons.length;

  List<BalloonComponent> getBalloonsInRadius(Vector2 center, double radius) {
    return activeBalloons.where((b) {
      return b.position.distanceTo(center) <= radius;
    }).toList();
  }

  void setSlowMotionAll(bool slow) {
    for (final balloon in _pool) {
      balloon.setSlowMotion(slow);
    }
  }

  void recycleAll() {
    for (final balloon in _pool) {
      balloon.recycle();
    }
  }
}
