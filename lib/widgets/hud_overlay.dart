import 'package:flutter/material.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';
import 'package:island_royale/widgets/joystick_widget.dart';
import 'package:island_royale/widgets/mini_map_widget.dart';
import 'package:island_royale/widgets/kill_feed_widget.dart';
import 'package:island_royale/widgets/weapon_slot_widget.dart';

class HudOverlay extends StatelessWidget {
  final IslandRoyaleGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── TOP LEFT: Kill feed ──────────────────────────────────
        Positioned(
          top: 12,
          left: 48,
          child: KillFeedWidget(notifier: game.killFeedNotifier),
        ),

        // ── TOP CENTER: Players alive ────────────────────────────
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(child: _PlayersAliveChip(notifier: game.playersAliveNotifier)),
        ),

        // ── TOP RIGHT: Mini-map ──────────────────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: MiniMapWidget(game: game),
        ),

        // ── BOTTOM: HUD bar ──────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomHud(game: game),
        ),

        // ── LEFT: Move Joystick ──────────────────────────────────
        Positioned(
          bottom: 80,
          left: 24,
          child: JoystickWidget(
            onMove: (dir) => game.onMoveJoystick(dir),
            label: 'MOVE',
          ),
        ),

        // ── RIGHT: Aim/Fire Joystick ─────────────────────────────
        Positioned(
          bottom: 80,
          right: 24,
          child: JoystickWidget(
            onMove: (dir) => game.onAimJoystick(dir),
            onRelease: () => game.fireBullet(),
            label: 'AIM',
            color: AppConstants.primaryColor,
          ),
        ),

        // ── ZONE TIMER bar ───────────────────────────────────────
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Center(child: _ZoneTimerBar(notifier: game.zoneTimerNotifier)),
        ),
      ],
    );
  }
}

// ── Players alive chip ───────────────────────────────────────────────────────
class _PlayersAliveChip extends StatelessWidget {
  final ValueNotifier<int> notifier;
  const _PlayersAliveChip({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (_, count, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppConstants.hudBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white54, size: 14),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const Text(
              ' ALIVE',
              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone shrink timer bar ────────────────────────────────────────────────────
class _ZoneTimerBar extends StatelessWidget {
  final ValueNotifier<double> notifier;
  const _ZoneTimerBar({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (_, val, __) {
        final frac = val / AppConstants.zoneShrinkDuration;
        return Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppConstants.hudBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ZONE', style: TextStyle(color: AppConstants.blueZoneColor, fontSize: 9, letterSpacing: 2)),
                  Text(
                    '${val.toInt()}s',
                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: frac,
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(AppConstants.blueZoneColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Bottom HUD bar ───────────────────────────────────────────────────────────
class _BottomHud extends StatelessWidget {
  final IslandRoyaleGame game;
  const _BottomHud({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(120, 10, 120, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // HP + Armor bars
          _StatBars(game: game),
          const SizedBox(width: 20),
          // Weapon slots
          WeaponSlotWidget(
            weaponNotifier: game.currentWeaponNotifier,
            ammoNotifier: game.ammoNotifier,
          ),
          const SizedBox(width: 20),
          // Kill count
          _KillCounter(notifier: game.killCountNotifier),
        ],
      ),
    );
  }
}

class _StatBars extends StatelessWidget {
  final IslandRoyaleGame game;
  const _StatBars({required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: game.healthNotifier,
            builder: (_, hp, __) => _Bar(
              label: 'HP',
              value: hp,
              max: 100,
              color: const Color(0xFF48BB78),
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<int>(
            valueListenable: game.armorNotifier,
            builder: (_, armor, __) => _Bar(
              label: 'ARM',
              value: armor,
              max: 100,
              color: const Color(0xFF63B3ED),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  const _Bar({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value / max,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _KillCounter extends StatelessWidget {
  final ValueNotifier<int> notifier;
  const _KillCounter({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (_, kills, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kills > 0
              ? AppConstants.primaryColor.withOpacity(0.25)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: kills > 0
                ? AppConstants.primaryColor.withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$kills',
              style: TextStyle(
                color: kills > 0 ? AppConstants.primaryColor : Colors.white38,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'KILLS',
              style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
