import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/game/components/bullet_component.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';

enum BotState { roaming, chasing, shooting, dead }

class BotComponent extends PositionComponent
    with HasGameRef<IslandRoyaleGame>, CollisionCallbacks {
  final String name;
  static const double _radius = 14.0;
  static const double _detectionRange = 220.0;
  static const double _shootRange = 180.0;
  static const double _shootCooldown = 1.2;

  int _health = 100;
  BotState _state = BotState.roaming;
  Vector2 _roamTarget = Vector2.zero();
  double _shootTimer = 0;
  final _rng = Random();

  BotComponent({required Vector2 position, required this.name})
      : super(
          position: position,
          size: Vector2.all(_radius * 2),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius));
    _pickNewRoamTarget();
  }

  void _pickNewRoamTarget() {
    _roamTarget = Vector2(
      50 + _rng.nextDouble() * (AppConstants.mapWidth - 100),
      50 + _rng.nextDouble() * (AppConstants.mapHeight - 100),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state == BotState.dead) return;

    final player = gameRef.localPlayer;
    final distToPlayer = position.distanceTo(player.position);

    // State transitions
    if (distToPlayer < _shootRange) {
      _state = BotState.shooting;
    } else if (distToPlayer < _detectionRange) {
      _state = BotState.chasing;
    } else {
      _state = BotState.roaming;
    }

    // Behaviour per state
    switch (_state) {
      case BotState.roaming:
        _moveToward(_roamTarget, 60.0, dt);
        if (position.distanceTo(_roamTarget) < 20) _pickNewRoamTarget();
        break;

      case BotState.chasing:
        _moveToward(player.position, 90.0, dt);
        break;

      case BotState.shooting:
        _shootTimer -= dt;
        if (_shootTimer <= 0) {
          _shootTimer = _shootCooldown;
          _fireBulletAtPlayer(player.position);
        }
        break;

      case BotState.dead:
        break;
    }

    position.x = position.x.clamp(_radius, AppConstants.mapWidth - _radius.toDouble());
    position.y = position.y.clamp(_radius, AppConstants.mapHeight - _radius.toDouble());
  }

  void _moveToward(Vector2 target, double speed, double dt) {
    final dir = (target - position);
    if (dir.length > 1) {
      position += dir.normalized() * speed * dt;
    }
  }

  void _fireBulletAtPlayer(Vector2 playerPos) {
    final dir = (playerPos - position).normalized();
    // Add slight inaccuracy
    dir.x += (_rng.nextDouble() - 0.5) * 0.3;
    dir.y += (_rng.nextDouble() - 0.5) * 0.3;

    gameRef.add(BulletComponent(
      position: position.clone(),
      direction: dir.normalized(),
      ownerId: name,
      weaponType: 'assault_rifle',
      fromBot: true,
    ));
  }

  void takeDamage(int amount) {
    _health = (_health - amount).clamp(0, 100);
    if (_health <= 0) _die();
  }

  void _die() {
    _state = BotState.dead;
    gameRef.recordKill(name);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (_state == BotState.dead) return;

    final center = Offset(size.x / 2, size.y / 2);

    // Shadow
    canvas.drawCircle(
      center + const Offset(2, 3),
      _radius,
      Paint()..color = Colors.black.withOpacity(0.35),
    );

    // Body - red enemy
    canvas.drawCircle(
      center,
      _radius,
      Paint()..color = const Color(0xFFE53E3E),
    );

    // Outline
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white70);

    // Health bar above bot
    final hpFrac = _health / 100.0;
    final barW = _radius * 2;
    const barH = 4.0;
    final barTop = Offset(0, -barH - 6);

    canvas.drawRect(
      Rect.fromLTWH(barTop.dx, barTop.dy, barW, barH),
      Paint()..color = Colors.black54,
    );
    canvas.drawRect(
      Rect.fromLTWH(barTop.dx, barTop.dy, barW * hpFrac, barH),
      Paint()..color = Color.lerp(Colors.red, Colors.green, hpFrac)!,
    );
  }

  bool get isDead => _state == BotState.dead;
}
