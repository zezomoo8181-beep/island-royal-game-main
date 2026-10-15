import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/utils/constants.dart';

class PlayerComponent extends PositionComponent with HasGameRef, CollisionCallbacks {
  final bool isLocal;
  Vector2 moveDirection = Vector2.zero();
  Vector2 aimDirection = Vector2(1, 0);
  bool _isDead = false;
  double _speed = AppConstants.playerSpeed;
  String equippedWeapon = 'assault_rifle';

  // Visual
  static const double _radius = 14.0;

  PlayerComponent({
    required Vector2 position,
    this.isLocal = false,
  }) : super(
          position: position,
          size: Vector2.all(_radius * 2),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius));
  }

  @override
  void render(Canvas canvas) {
    if (_isDead) return;

    final center = Offset(size.x / 2, size.y / 2);

    // Shadow
    canvas.drawCircle(
      center + const Offset(2, 3),
      _radius,
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    // Body
    canvas.drawCircle(
      center,
      _radius,
      Paint()..color = isLocal ? const Color(0xFF4CAF50) : const Color(0xFFE53E3E),
    );

    // Outline
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Direction indicator (barrel)
    final barrelEnd = center +
        Offset(aimDirection.x * (_radius + 10), aimDirection.y * (_radius + 10));
    canvas.drawLine(
      center,
      barrelEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Inner dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDead) return;

    if (moveDirection.length > 0) {
      final dir = moveDirection.normalized();
      position += dir * _speed * dt;
      _clampToMap();
    }
  }

  void _clampToMap() {
    position.x = position.x.clamp(_radius, AppConstants.mapWidth - _radius.toDouble());
    position.y = position.y.clamp(_radius, AppConstants.mapHeight - _radius.toDouble());
  }

  void die() {
    _isDead = true;
    moveDirection = Vector2.zero();
  }

  void applySpeedBoost(double multiplier, double duration) {
    _speed = AppConstants.playerSpeed * multiplier;
    Future.delayed(Duration(seconds: duration.toInt()), () {
      _speed = AppConstants.playerSpeed;
    });
  }

  bool get isDead => _isDead;
}
