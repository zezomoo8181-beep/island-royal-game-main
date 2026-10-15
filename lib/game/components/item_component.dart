import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/game/components/player_component.dart';
import 'package:island_royale/game/island_royale_game.dart';

class ItemComponent extends PositionComponent
    with HasGameRef<IslandRoyaleGame>, CollisionCallbacks {
  final String itemType;
  static const double _size = 20.0;
  double _bobTimer = 0;

  static const Map<String, Color> _itemColors = {
    'pistol': Color(0xFFFFD700),
    'shotgun': Color(0xFFFF6600),
    'assault_rifle': Color(0xFF00BFFF),
    'sniper': Color(0xFF9B59B6),
    'bandage': Color(0xFF2ECC71),
    'medkit': Color(0xFF27AE60),
    'ammo': Color(0xFFF39C12),
    'armor': Color(0xFF95A5A6),
  };

  ItemComponent({required Vector2 position, required this.itemType})
      : super(
          position: position,
          size: Vector2.all(_size),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _size / 2, isSolid: false));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt * 2;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && other.isLocal) {
      _applyPickup();
      removeFromParent();
    }
  }

  void _applyPickup() {
    final game = gameRef;
    switch (itemType) {
      case 'bandage':
        game.healthNotifier.value = (game.healthNotifier.value + 10).clamp(0, 100);
        break;
      case 'medkit':
        game.healthNotifier.value = 100;
        break;
      case 'armor':
        game.armorNotifier.value = (game.armorNotifier.value + 50).clamp(0, 100);
        break;
      case 'ammo':
        game.ammoNotifier.value = (game.ammoNotifier.value + 30).clamp(0, 90);
        break;
      case 'pistol':
      case 'shotgun':
      case 'assault_rifle':
      case 'sniper':
        game.currentWeaponNotifier.value = itemType;
        game.ammoNotifier.value = _defaultAmmo(itemType);
        break;
    }
  }

  int _defaultAmmo(String weapon) {
    switch (weapon) {
      case 'pistol': return 12;
      case 'shotgun': return 6;
      case 'sniper': return 5;
      default: return 30;
    }
  }

  @override
  void render(Canvas canvas) {
    final color = _itemColors[itemType] ?? Colors.white;
    final bobOffset = math.sin(_bobTimer) * 2.0;
    final cx = size.x / 2;
    final cy = size.y / 2 + bobOffset;

    canvas.drawCircle(Offset(cx, cy), _size / 2 + 2,
        Paint()
          ..color = color.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawCircle(Offset(cx, cy), _size / 2,
        Paint()..color = color.withOpacity(0.85));

    canvas.drawCircle(Offset(cx, cy), _size / 2,
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    final tp = TextPainter(
      text: TextSpan(
        text: _shortLabel(itemType),
        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  String _shortLabel(String type) {
    const labels = {
      'pistol': 'P', 'shotgun': 'SG', 'assault_rifle': 'AR', 'sniper': 'SR',
      'bandage': '+10', 'medkit': 'MED', 'ammo': 'AMO', 'armor': 'ARM',
    };
    return labels[type] ?? type[0].toUpperCase();
  }
}
