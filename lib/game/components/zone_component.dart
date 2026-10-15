import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';

class ZoneComponent extends PositionComponent with HasGameRef<IslandRoyaleGame> {
  double _currentRadius;
  double _targetRadius;
  final Vector2 _center;
  double _phaseTimer = 0;
  int _phase = 0;
  double _damageTimer = 0;

  static const double _shrinkSpeed = 20.0; // px per second during shrink
  static const double _waitDuration = 60.0; // seconds before shrink starts
  static const List<double> _phaseRadii = [450, 300, 180, 80, 30];

  ZoneComponent({required IslandRoyaleGame game})
      : _currentRadius = AppConstants.initialZoneRadius,
        _targetRadius = AppConstants.initialZoneRadius,
        _center = Vector2(
          AppConstants.mapWidth / 2.0,
          AppConstants.mapHeight / 2.0,
        ),
        super(position: Vector2.zero(), size: Vector2.all(0));

  @override
  void update(double dt) {
    super.update(dt);

    _phaseTimer += dt;

    // Wait then shrink to next phase
    if (_phaseTimer >= _waitDuration && _phase < _phaseRadii.length - 1) {
      _targetRadius = _phaseRadii[_phase + 1];

      if (_currentRadius > _targetRadius) {
        _currentRadius -= _shrinkSpeed * dt;
        if (_currentRadius <= _targetRadius) {
          _currentRadius = _targetRadius;
          _phase++;
          _phaseTimer = 0;
        }
      }
    }

    // Damage player if outside zone
    final playerPos = gameRef.localPlayer.position;
    final dist = playerPos.distanceTo(_center);
    if (dist > _currentRadius) {
      _damageTimer += dt;
      if (_damageTimer >= 1.0) {
        _damageTimer = 0;
        gameRef.applyDamage(AppConstants.zoneDamagePerSecond.toInt());
      }
    } else {
      _damageTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    _drawZone(canvas);
  }

  void _drawZone(Canvas canvas) {
    final cx = _center.x;
    final cy = _center.y;

    // Blue zone danger area (outside the safe circle)
    // Draw as a large filled rect minus the safe circle
    final outerRect = Rect.fromLTWH(
      -AppConstants.mapWidth.toDouble(),
      -AppConstants.mapHeight.toDouble(),
      AppConstants.mapWidth * 3.0,
      AppConstants.mapHeight * 3.0,
    );

    final path = Path()
      ..addRect(outerRect)
      ..addOval(Rect.fromCircle(
          center: Offset(cx, cy), radius: _currentRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = const Color(0x553182CE),
    );

    // Zone border ring
    canvas.drawCircle(
      Offset(cx, cy),
      _currentRadius,
      Paint()
        ..color = const Color(0xFF63B3ED)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Animated dashes on the border
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const int dashCount = 32;
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * math.pi * 2 + now * 0.5;
      final x1 = cx + math.cos(angle) * (_currentRadius - 6);
      final y1 = cy + math.sin(angle) * (_currentRadius - 6);
      final x2 = cx + math.cos(angle) * (_currentRadius + 6);
      final y2 = cy + math.sin(angle) * (_currentRadius + 6);
      if (i.isEven) canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
    }
  }

  double get currentRadius => _currentRadius;
  Vector2 get center => _center;
}
