import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_royale/utils/constants.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  int _playerCount = 1;
  int _botCount = 0;
  Timer? _fillTimer;
  bool _isSearching = true;
  static const int _targetPlayers = AppConstants.maxPlayers;

  @override
  void initState() {
    super.initState();
    _startFilling();
  }

  void _startFilling() {
    _fillTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) return;
      setState(() {
        if (_playerCount < 8) {
          _playerCount++;
        } else {
          _botCount = (_targetPlayers - _playerCount).clamp(0, _targetPlayers);
          t.cancel();
          _isSearching = false;
        }
      });
    });
  }

  void _launchGame() {
    context.go('/game?roomId=room_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  void dispose() {
    _fillTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _playerCount + _botCount;
    final fillPercent = total / _targetPlayers;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white54),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MATCHMAKING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  const Spacer(),
                  if (_isSearching)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Player count display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            ' / $_targetPlayers',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'PLAYERS',
                      style: TextStyle(
                        color: Colors.white38,
                        letterSpacing: 4,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Fill bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fillPercent,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                            AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(
                            label: 'REAL', value: '$_playerCount', isGood: true),
                        _StatChip(label: 'BOTS', value: '$_botCount'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Game mode info
              _InfoRow(icon: Icons.map, label: 'MAP', value: 'Emerald Island'),
              _InfoRow(icon: Icons.person, label: 'MODE', value: 'Solo (FPP)'),
              _InfoRow(
                  icon: Icons.grid_on,
                  label: 'MAP SIZE',
                  value: '1000 x 1000'),

              const Spacer(),

              // Start button
              if (!_isSearching)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _launchGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'DEPLOY NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (_isSearching)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white54,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _StatChip({required this.label, required this.value, this.isGood = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGood ? Colors.greenAccent : Colors.white38,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: TextStyle(
            color: isGood ? Colors.greenAccent : Colors.white38,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 12, letterSpacing: 2),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
