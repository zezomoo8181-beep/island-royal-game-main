import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appTitle = 'Island Royale';
  static const Color primaryColor = Color(0xFFFF6B00);
  static const Color dangerColor = Color(0xFFE53E3E);
  static const Color safeZoneColor = Color(0xFF3182CE);
  static const Color blueZoneColor = Color(0xFF63B3ED);
  static const Color hudBackground = Color(0xAA000000);

  // Game config
  static const int maxPlayers = 30;
  static const int mapWidth = 1000;
  static const int mapHeight = 1000;
  static const int tileSize = 32;
  static const double playerSpeed = 150.0;
  static const double bulletSpeed = 600.0;

  // Network
  static const String wsUrl = 'ws://localhost:8080/game';
  static const int syncIntervalMs = 50; // 20 times/sec
  static const int maxPing = 100;

  // Blue Zone
  static const double initialZoneRadius = 450.0;
  static const double finalZoneRadius = 30.0;
  static const double zoneShrinkDuration = 120.0; // seconds per phase
  static const double zoneDamagePerSecond = 5.0;

  // Weapon ranges (in pixels)
  static const Map<String, double> weaponRanges = {
    'pistol': 200.0,
    'shotgun': 120.0,
    'assault_rifle': 350.0,
    'sniper': 600.0,
  };

  // Hive box names
  static const String settingsBox = 'settings';
  static const String playerBox = 'player';
}
