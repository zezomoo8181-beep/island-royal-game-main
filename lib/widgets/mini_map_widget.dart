import 'package:flutter/material.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';

class MiniMapWidget extends StatefulWidget {
  final IslandRoyaleGame game;
  const MiniMapWidget({super.key, required this.game});

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  static const double _mapSize = 90.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: _mapSize,
        height: _mapSize,
        color: const Color(0xCC0A1A0A),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.game.healthNotifier, // repaints when state changes
            widget.game.playersAliveNotifier,
          ]),
          builder: (_, __) => CustomPaint(
            painter: _MiniMapPainter(game: widget.game),
          ),
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final IslandRoyaleGame game;
  const _MiniMapPainter({required this.game});

  double _mapX(double worldX, double w) =>
      (worldX / AppConstants.mapWidth) * w;
  double _mapY(double worldY, double h) =>
      (worldY / AppConstants.mapHeight) * h;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A2E1A),
    );

    // Blue zone circle
    final zone = game.blueZone;
    final zoneR = (zone.currentRadius / AppConstants.mapWidth) * size.width;
    final zx = _mapX(zone.center.x, size.width);
    final zy = _mapY(zone.center.y, size.height);

    canvas.drawCircle(
      Offset(zx, zy),
      zoneR,
      Paint()
        ..color = const Color(0x333182CE)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(zx, zy),
      zoneR,
      Paint()
        ..color = const Color(0xFF63B3ED)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Bots as red dots
    for (final bot in game.bots) {
      if (bot.isDead) continue;
      final bx = _mapX(bot.position.x, size.width);
      final by = _mapY(bot.position.y, size.height);
      canvas.drawCircle(Offset(bx, by), 2, Paint()..color = const Color(0xFFE53E3E));
    }

    // Local player as green dot (always on top)
    final px = _mapX(game.localPlayer.position.x, size.width);
    final py = _mapY(game.localPlayer.position.y, size.height);
    canvas.drawCircle(Offset(px, py), 3.5, Paint()..color = Colors.black54);
    canvas.drawCircle(Offset(px, py), 3, Paint()..color = const Color(0xFF4CAF50));

    // Border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Compass
    const compassStyle = TextStyle(color: Colors.white24, fontSize: 7);
    _drawText(canvas, 'N', Offset(size.width / 2 - 3, 2), compassStyle);
    _drawText(canvas, 'S', Offset(size.width / 2 - 3, size.height - 10), compassStyle);
    _drawText(canvas, 'W', Offset(2, size.height / 2 - 4), compassStyle);
    _drawText(canvas, 'E', Offset(size.width - 8, size.height / 2 - 4), compassStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_MiniMapPainter old) => true;
}
