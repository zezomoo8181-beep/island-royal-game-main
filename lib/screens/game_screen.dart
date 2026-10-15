import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/widgets/hud_overlay.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  const GameScreen({super.key, required this.roomId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late IslandRoyaleGame _game;

  @override
  void initState() {
    super.initState();
    _game = IslandRoyaleGame(roomId: widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Flame game canvas fills the entire screen
          GameWidget(
            game: _game,
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B00),
              ),
            ),
          ),

          // Flutter HUD layered on top
          HudOverlay(game: _game),

          // Pause button (top-left)
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: GestureDetector(
                onTap: _showPauseMenu,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white70, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu() {
    _game.pauseEngine();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PauseButton(
              label: 'RESUME',
              icon: Icons.play_arrow,
              color: const Color(0xFFFF6B00),
              onTap: () {
                Navigator.pop(context);
                _game.resumeEngine();
              },
            ),
            const SizedBox(height: 12),
            _PauseButton(
              label: 'QUIT TO MENU',
              icon: Icons.exit_to_app,
              color: Colors.white24,
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PauseButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(letterSpacing: 2, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
