import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_royale/utils/constants.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A2A1A), Color(0xFF0A0F0A)],
          ),
        ),
        child: Stack(
          children: [
            // Background grid pattern
            CustomPaint(
              painter: _GridPainter(),
              size: Size.infinite,
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Column(
                      children: [
                        Text(
                          'ISLAND',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 16,
                            shadows: [
                              Shadow(
                                color: AppConstants.primaryColor.withOpacity(0.8),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ROYALE',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                            letterSpacing: 12,
                            shadows: [
                              Shadow(
                                color: AppConstants.primaryColor,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LAST SURVIVOR WINS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Buttons
                  _MenuButton(
                    label: 'START MATCH',
                    isPrimary: true,
                    icon: Icons.sports_esports,
                    onTap: () => context.push('/lobby'),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'LEADERBOARD',
                    icon: Icons.emoji_events,
                    onTap: () => context.push('/leaderboard'),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'SETTINGS',
                    icon: Icons.settings,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),

            // Version tag
            Positioned(
              bottom: 16,
              right: 20,
              child: Text(
                'v1.0.0 MVP',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.onTap,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 260,
        height: 52,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppConstants.primaryColor
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPrimary
                ? AppConstants.primaryColor
                : Colors.white.withOpacity(0.15),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
