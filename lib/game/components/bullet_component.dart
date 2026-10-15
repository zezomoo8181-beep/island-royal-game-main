import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/game/components/bot_component.dart';
import 'package:island_royale/game/components/player_component.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';

class BulletComponent extends PositionComponent
    with HasGameRef<IslandRoyaleGame>, CollisionCallbacks {
  final Vector2 direction;
  final String ownerId;
  final String weaponType;
  final bool fromBot;

  double _distanceTravelled = 0;
  late double _maxRange;
  late double _damage;
  late double _speed;
  late Color _color;

  static const double _bulletRadius = 4.0;

  BulletComponent({
    required Vector2 position,
    required this.direction,
    required this.ownerId,
    required this.weaponType,
    this.fromBot = false,
  }) : super(
          position: position,
          size: Vector2.all(_bulletRadius * 2),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Weapon-specific properties
    switch (weaponType) {
      case 'pistol':
        _damage = 25;
        _speed = AppConstants.bulletSpeed * 0.8;
        _maxRange = AppConstants.weaponRanges['pistol']!;
        _color = Colors.yellow;
        break;
      case 'shotgun':
        _damage = 50;
        _speed = AppConstants.bulletSpeed * 0.7;
        _maxRange = AppConstants.weaponRanges['shotgun']!;
        _color = Colors.orange;
        break;
      case 'sniper':
        _damage = 95;
        _speed = AppConstants.bulletSpeed * 1.5;
        _maxRange = AppConstants.weaponRanges['sniper']!;
        _color = Colors.cyanAccent;
        break;
      case 'assault_rifle':
      default:
        _damage = 35;
        _speed = AppConstants.bulletSpeed;
        _maxRange = AppConstants.weaponRanges['assault_rifle']!;
        _color = const Color(0xFFFFD700);
        break;
    }

    add(CircleHitbox(radius: _bulletRadius));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final step = direction * _speed * dt;
    position += step;
    _distanceTravelled += step.length;

    // Remove if out of range or off map
    if (_distanceTravelled >= _maxRange ||
        position.x < 0 ||
        position.x > AppConstants.mapWidth ||
        position.y < 0 ||
        position.y > AppConstants.mapHeight) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Bot bullet hits local player
    if (fromBot && other is PlayerComponent && other.isLocal) {
      gameRef.applyDamage(_damage.toInt());
      removeFromParent();
      return;
    }

    // Player bullet hits bot
    if (!fromBot && other is BotComponent) {
      other.takeDamage(_damage.toInt());
      removeFromParent();
      return;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    // Glow effect
    canvas.drawCircle(
      center,
      _bulletRadius + 3,
      Paint()
        ..color = _color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Core bullet
    canvas.drawCircle(
      center,
      _bulletRadius,
      Paint()..color = _color,
    );

    // White hot center
    canvas.drawCircle(
      center,
      _bulletRadius * 0.4,
      Paint()..color = Colors.white,
    );
  }
}
