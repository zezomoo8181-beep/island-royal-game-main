import 'package:flutter/material.dart';
import 'package:island_royale/utils/constants.dart';

class WeaponSlotWidget extends StatelessWidget {
  final ValueNotifier<String> weaponNotifier;
  final ValueNotifier<int> ammoNotifier;

  const WeaponSlotWidget({
    super.key,
    required this.weaponNotifier,
    required this.ammoNotifier,
  });

  static const Map<String, IconData> _weaponIcons = {
    'pistol': Icons.radio_button_checked,
    'shotgun': Icons.view_week,
    'assault_rifle': Icons.linear_scale,
    'sniper': Icons.zoom_in,
  };

  static const Map<String, String> _weaponLabels = {
    'pistol': 'PISTOL',
    'shotgun': 'SHOTGUN',
    'assault_rifle': 'AR',
    'sniper': 'SNIPER',
  };

  static const Map<String, Color> _weaponColors = {
    'pistol': Color(0xFFFFD700),
    'shotgun': Color(0xFFFF6600),
    'assault_rifle': Color(0xFF00BFFF),
    'sniper': Color(0xFF9B59B6),
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: weaponNotifier,
      builder: (_, weapon, __) {
        final color = _weaponColors[weapon] ?? Colors.white;
        final icon = _weaponIcons[weapon] ?? Icons.radio_button_checked;
        final label = _weaponLabels[weapon] ?? weapon.toUpperCase();

        return ValueListenableBuilder<int>(
          valueListenable: ammoNotifier,
          builder: (_, ammo, __) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.white38),
                          const SizedBox(width: 3),
                          Text(
                            '$ammo',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            ' AMMO',
                            style: TextStyle(
                                color: Colors.white30,
                                fontSize: 9,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (ammo == 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.dangerColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'EMPTY',
                        style: TextStyle(
                            color: AppConstants.dangerColor,
                            fontSize: 8,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
