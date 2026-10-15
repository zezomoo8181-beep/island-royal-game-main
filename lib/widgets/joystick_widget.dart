import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class JoystickWidget extends StatefulWidget {
  final void Function(Vector2 direction) onMove;
  final VoidCallback? onRelease;
  final String label;
  final Color color;

  const JoystickWidget({
    super.key,
    required this.onMove,
    this.onRelease,
    this.label = 'MOVE',
    this.color = const Color(0xFF4A9EFF),
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  static const double _baseRadius = 52.0;
  static const double _thumbRadius = 22.0;

  Offset _thumbOffset = Offset.zero;
  bool _active = false;

  void _handlePanStart(DragStartDetails d) {
    setState(() => _active = true);
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    final raw = d.localPosition - Offset(_baseRadius, _baseRadius);
    final dist = raw.distance;
    final clamped = dist > _baseRadius - _thumbRadius
        ? raw / dist * (_baseRadius - _thumbRadius)
        : raw;

    setState(() => _thumbOffset = clamped);

    final norm = dist > 1
        ? Offset(raw.dx / dist, raw.dy / dist)
        : Offset.zero;
    widget.onMove(Vector2(norm.dx, norm.dy));
  }

  void _handlePanEnd(DragEndDetails d) {
    setState(() {
      _thumbOffset = Offset.zero;
      _active = false;
    });
    widget.onMove(Vector2.zero());
    widget.onRelease?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: _baseRadius * 2,
        height: _baseRadius * 2,
        child: CustomPaint(
          painter: _JoystickPainter(
            thumbOffset: _thumbOffset,
            active: _active,
            color: widget.color,
            thumbRadius: _thumbRadius,
            baseRadius: _baseRadius,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset thumbOffset;
  final bool active;
  final Color color;
  final double thumbRadius;
  final double baseRadius;

  const _JoystickPainter({
    required this.thumbOffset,
    required this.active,
    required this.color,
    required this.thumbRadius,
    required this.baseRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Base ring
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = Colors.white.withOpacity(active ? 0.12 : 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = color.withOpacity(active ? 0.6 : 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Direction guides
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawLine(
        center + Offset(math.cos(angle) * 14, math.sin(angle) * 14),
        center + Offset(math.cos(angle) * (baseRadius - 6), math.sin(angle) * (baseRadius - 6)),
        guidePaint,
      );
    }

    // Thumb shadow
    canvas.drawCircle(
      center + thumbOffset + const Offset(2, 3),
      thumbRadius,
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Thumb
    canvas.drawCircle(
      center + thumbOffset,
      thumbRadius,
      Paint()
        ..color = active
            ? color.withOpacity(0.9)
            : Colors.white.withOpacity(0.25),
    );

    // Thumb ring
    canvas.drawCircle(
      center + thumbOffset,
      thumbRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner dot
    canvas.drawCircle(
      center + thumbOffset,
      5,
      Paint()..color = Colors.white.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.thumbOffset != thumbOffset || old.active != active;
}
