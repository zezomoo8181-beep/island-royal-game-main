# 🏝️ Island Royale

A 2D top-down Battle Royale game inspired by PUBG, built with **Flutter + Flame Engine**.
Cross-platform: iOS, Android, and Web from a single codebase.

---

## 📁 Project Structure

```
island_royale/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── game/
│   │   ├── island_royale_game.dart      # Main FlameGame class
│   │   ├── components/
│   │   │   ├── player_component.dart    # Local & remote players
│   │   │   ├── bot_component.dart       # AI enemies (FSM)
│   │   │   ├── bullet_component.dart    # Projectile logic
│   │   │   ├── item_component.dart      # Loot / pickups
│   │   │   └── zone_component.dart      # Shrinking blue zone
│   │   ├── systems/
│   │   │   └── network_system.dart      # WebSocket + Isolate decode
│   │   └── world/
│   │       └── tile_map.dart            # Procedural tilemap
│   ├── screens/
│   │   ├── main_menu_screen.dart
│   │   ├── lobby_screen.dart
│   │   ├── game_screen.dart             # GameWidget + HUD stack
│   │   ├── settings_screen.dart
│   │   └── leaderboard_screen.dart
│   ├── widgets/
│   │   ├── hud_overlay.dart             # Full HUD (HP, ammo, map, feed)
│   │   ├── joystick_widget.dart         # Dual 360° virtual joysticks
│   │   ├── mini_map_widget.dart         # Radar mini-map
│   │   ├── kill_feed_widget.dart        # Scrolling kill feed
│   │   └── weapon_slot_widget.dart      # Weapon + ammo display
│   ├── models/
│   │   ├── player_model.dart
│   │   └── weapon_model.dart
│   └── utils/
│       ├── constants.dart               # All game constants
│       └── app_router.dart              # go_router navigation
├── server/
│   ├── server.js                        # Node.js WebSocket server
│   └── package.json
├── assets/
│   ├── images/                          # Sprites (add your own)
│   ├── audio/                           # Sound effects
│   └── tilemaps/                        # Tiled map files
├── pubspec.yaml
└── README.md
```

---

## ⚡ Quick Start

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Node.js | ≥ 18.x |
| Android Studio / Xcode | Latest |

---

## 🛠️ Flutter App Commands

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run on Android (connected device or emulator)
```bash
flutter run -d android
```

### 3. Run on iOS (requires macOS + Xcode)
```bash
flutter run -d ios
```

### 4. Run on Web (Chrome)
```bash
flutter run -d chrome --web-renderer canvaskit
```

### 5. Run on macOS desktop
```bash
flutter run -d macos
```

### 6. Build release APK (Android)
```bash
flutter build apk --release --split-per-abi
# Output: build/app/outputs/flutter-apk/
```

### 7. Build release App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 8. Build release IPA (iOS — requires Xcode signing)
```bash
flutter build ipa --release
# Output: build/ios/archive/
```

### 9. Build Web release
```bash
flutter build web --web-renderer canvaskit --release
# Output: build/web/
```

### 10. Run all tests
```bash
flutter test
```

### 11. Run with verbose logging
```bash
flutter run -d android --verbose
```

### 12. Check Flutter environment
```bash
flutter doctor -v
```

### 13. Analyze code for issues
```bash
flutter analyze
```

### 14. Format all Dart files
```bash
dart format lib/
```

### 15. Clean build cache
```bash
flutter clean
flutter pub get
```

### 16. List connected devices
```bash
flutter devices
```

### 17. Run in release mode on device (best perf)
```bash
flutter run --release -d <device_id>
```

### 18. Enable performance overlay
```bash
flutter run --profile -d android
```
(Then tap the Performance Overlay button in the debug menu)

---

## 🖥️ Game Server Commands (Node.js)

### Navigate to server directory
```bash
cd server/
```

### Install server dependencies
```bash
npm install
```

### Start the game server
```bash
npm start
# Server runs on ws://localhost:8080
```

### Start with auto-reload (development)
```bash
npm run dev
# Requires nodemon (installed via npm install)
```

### Test WebSocket connection manually
```bash
# Install wscat globally
npm install -g wscat

# Connect to default room
wscat -c ws://localhost:8080/game/test_room

# Send a test player update
{"type":"player_update","x":500,"y":500,"aimX":1,"aimY":0,"hp":100,"weapon":"assault_rifle"}
```

---

## 🔧 Configuration

### Change server URL (for production)
Edit `lib/utils/constants.dart`:
```dart
static const String wsUrl = 'wss://your-production-server.com/game';
```

### Adjust game balance
All tunable values live in `lib/utils/constants.dart`:
```dart
static const int maxPlayers = 30;
static const double playerSpeed = 150.0;
static const double bulletSpeed = 600.0;
static const double zoneDamagePerSecond = 5.0;
```

---

## 🏗️ Architecture

```
Flutter UI (HUD widgets)
        │ ValueNotifier (reactive, zero rebuild cost)
        ▼
  FlameGame (IslandRoyaleGame)
  ├─ GameTileMap        — procedural world
  ├─ PlayerComponent    — local player (joystick-driven)
  ├─ BotComponent × N   — FSM AI (roam → chase → shoot)
  ├─ BulletComponent    — physics + collision
  ├─ ItemComponent      — loot + auto-pickup
  ├─ ZoneComponent      — blue zone shrink + damage
  └─ NetworkSystem      — WebSocket + Dart Isolate decode
```

---

## 🎮 Controls (In-Game)

| Control | Action |
|---------|--------|
| Left Joystick | Move player (360°) |
| Right Joystick drag | Aim |
| Right Joystick release | Fire |
| Walk over item | Auto-pickup |
| ☰ menu button | Pause / Quit |

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flame ^1.18` | 2D game engine & render loop |
| `flame_forge2d ^0.18` | Physics & collision detection |
| `flutter_bloc ^8` | State management |
| `web_socket_channel ^2` | Real-time multiplayer |
| `go_router ^13` | Navigation |
| `shared_preferences ^2` | Settings persistence |
| `hive ^2` | Fast local storage |
| `in_app_purchase ^3` | Cosmetic IAP |

---

## 🗺️ MVP → Phase 2 Roadmap

| Feature | MVP ✅ | Phase 2 |
|---------|--------|---------|
| Solo match (20 players) | ✅ | Squad/Duo + voice chat |
| Bot AI | ✅ | Skill-based SBMM |
| Blue zone | ✅ | Dynamic storms |
| Loot system | ✅ | Attachments, scopes |
| Mini-map | ✅ | Full map screen |
| WebSocket sync | ✅ | UDP (gRPC) for lower latency |
| Map size 1000×1000 | ✅ | 2000×2000 + vehicles |
| Basic audio | — | Spatial directional audio |

---

## 📄 License

MIT License — free to use and modify.
