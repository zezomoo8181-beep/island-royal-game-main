import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/utils/constants.dart';

/// Tile types
enum TileType { grass, dirt, water, rock, building, road }

class GameTileMap extends Component with HasGameRef {
  static const int cols = AppConstants.mapWidth ~/ AppConstants.tileSize;
  static const int rows = AppConstants.mapHeight ~/ AppConstants.tileSize;

  late List<List<TileType>> _tiles;
  final _rng = math.Random(42); // fixed seed for reproducibility

  // Building rectangles for collision reference
  final List<Rect> buildings = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generateMap();
  }

  void _generateMap() {
    _tiles = List.generate(rows, (_) => List.filled(cols, TileType.grass));

    // Outer water border
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (r < 2 || r >= rows - 2 || c < 2 || c >= cols - 2) {
          _tiles[r][c] = TileType.water;
        }
      }
    }

    // Dirt patches
    for (int i = 0; i < 18; i++) {
      final pr = 4 + _rng.nextInt(rows - 8);
      final pc = 4 + _rng.nextInt(cols - 8);
      final w = 2 + _rng.nextInt(6);
      final h = 2 + _rng.nextInt(6);
      _fillRect(pr, pc, h, w, TileType.dirt);
    }

    // Rock clusters
    for (int i = 0; i < 12; i++) {
      final pr = 4 + _rng.nextInt(rows - 8);
      final pc = 4 + _rng.nextInt(cols - 8);
      _fillRect(pr, pc, 2, 2, TileType.rock);
    }

    // Roads
    final midRow = rows ~/ 2;
    final midCol = cols ~/ 2;
    for (int c = 2; c < cols - 2; c++) _tiles[midRow][c] = TileType.road;
    for (int r = 2; r < rows - 2; r++) _tiles[r][midCol] = TileType.road;

    // Buildings (compound areas)
    _placeBuildings();
  }

  void _fillRect(int r, int c, int h, int w, TileType type) {
    for (int dr = 0; dr < h; dr++) {
      for (int dc = 0; dc < w; dc++) {
        final nr = r + dr;
        final nc = c + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
          _tiles[nr][nc] = type;
        }
      }
    }
  }

  void _placeBuildings() {
    final positions = [
      [5, 5], [5, 20], [20, 5], [20, 20],
      [12, 12], [8, 28], [28, 8], [25, 25],
    ];
    for (final pos in positions) {
      final r = pos[0], c = pos[1];
      final w = 3 + _rng.nextInt(3);
      final h = 3 + _rng.nextInt(3);
      _fillRect(r, c, h, w, TileType.building);
      buildings.add(Rect.fromLTWH(
        c * AppConstants.tileSize.toDouble(),
        r * AppConstants.tileSize.toDouble(),
        w * AppConstants.tileSize.toDouble(),
        h * AppConstants.tileSize.toDouble(),
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * AppConstants.tileSize.toDouble(),
          r * AppConstants.tileSize.toDouble(),
          AppConstants.tileSize.toDouble(),
          AppConstants.tileSize.toDouble(),
        );
        canvas.drawRect(rect, Paint()..color = _tileColor(_tiles[r][c]));
      }
    }

    // Grid lines (subtle)
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(
        Offset(0, r * AppConstants.tileSize.toDouble()),
        Offset(AppConstants.mapWidth.toDouble(),
            r * AppConstants.tileSize.toDouble()),
        gridPaint,
      );
    }
    for (int c = 0; c <= cols; c++) {
      canvas.drawLine(
        Offset(c * AppConstants.tileSize.toDouble(), 0),
        Offset(c * AppConstants.tileSize.toDouble(),
            AppConstants.mapHeight.toDouble()),
        gridPaint,
      );
    }

    // Building walls
    for (final b in buildings) {
      canvas.drawRect(
        b,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Color _tileColor(TileType type) {
    switch (type) {
      case TileType.grass:
        return const Color(0xFF2D5A1B);
      case TileType.dirt:
        return const Color(0xFF7A5C3A);
      case TileType.water:
        return const Color(0xFF1A3A5C);
      case TileType.rock:
        return const Color(0xFF4A4A4A);
      case TileType.building:
        return const Color(0xFF3A3530);
      case TileType.road:
        return const Color(0xFF3D3D3D);
    }
  }
}
