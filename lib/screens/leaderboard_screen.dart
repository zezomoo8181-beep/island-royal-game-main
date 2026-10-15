import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_royale/utils/constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static final List<Map<String, dynamic>> _mockData = [
    {'rank': 1, 'name': 'ShadowSniper', 'wins': 142, 'kills': 1893, 'kd': 4.7},
    {'rank': 2, 'name': 'NightHawk', 'wins': 118, 'kills': 1542, 'kd': 4.1},
    {'rank': 3, 'name': 'BlitzKrieg', 'wins': 95, 'kills': 1320, 'kd': 3.8},
    {'rank': 4, 'name': 'DesertEagle', 'wins': 87, 'kills': 1210, 'kd': 3.4},
    {'rank': 5, 'name': 'IronSight', 'wins': 76, 'kills': 1085, 'kd': 3.1},
    {'rank': 6, 'name': 'VortexAce', 'wins': 65, 'kills': 980, 'kd': 2.9},
    {'rank': 7, 'name': 'StormBreaker', 'wins': 54, 'kills': 876, 'kd': 2.6},
    {'rank': 8, 'name': 'GhostRider', 'wins': 43, 'kills': 720, 'kd': 2.3},
    {'rank': 9, 'name': 'PixelWarrior', 'wins': 32, 'kills': 612, 'kd': 2.0},
    {'rank': 10, 'name': 'QuickShot', 'wins': 21, 'kills': 510, 'kd': 1.8},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.emoji_events,
                color: Colors.amber.withOpacity(0.7)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: const [
                SizedBox(width: 40, child: _HeaderCell('#')),
                Expanded(flex: 3, child: _HeaderCell('PLAYER')),
                Expanded(child: _HeaderCell('WINS')),
                Expanded(child: _HeaderCell('KILLS')),
                Expanded(child: _HeaderCell('K/D')),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _mockData.length,
              itemBuilder: (context, index) {
                final entry = _mockData[index];
                final rank = entry['rank'] as int;
                return _LeaderboardRow(entry: entry, rank: rank);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int rank;

  const _LeaderboardRow({required this.entry, required this.rank});

  Color get _rankColor {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.white70;
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.white30;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withOpacity(0.07)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: rank <= 3 ? _rankColor.withOpacity(0.2) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entry['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${entry['wins']}',
              style: const TextStyle(
                  color: AppConstants.primaryColor, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              '${entry['kills']}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              '${entry['kd']}',
              style: TextStyle(
                color: (entry['kd'] as double) >= 3.0
                    ? Colors.greenAccent
                    : Colors.white60,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
