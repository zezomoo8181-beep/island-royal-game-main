import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:island_royale/game/components/player_component.dart';
import 'package:island_royale/game/components/bot_component.dart';
import 'package:island_royale/game/components/bullet_component.dart';
import 'package:island_royale/game/components/item_component.dart';
import 'package:island_royale/game/components/zone_component.dart';
import 'package:island_royale/game/systems/network_system.dart';
import 'package:island_royale/game/world/tile_map.dart';
import 'package:island_royale/utils/constants.dart';

/// The main Flame game class.
/// All game logic, rendering, and state management lives here.
class IslandRoyaleGame extends FlameGame
    with HasCollisionDetection,TapCallbacks, DragCallbacks {
  final String roomId;

  // Notifiers so Flutter HUD widgets can reactively update
  final ValueNotifier<int> healthNotifier = ValueNotifier(100);
  final ValueNotifier<int> armorNotifier = ValueNotifier(0);
  final ValueNotifier<int> ammoNotifier = ValueNotifier(30);
  final ValueNotifier<int> killCountNotifier = ValueNotifier(0);
  final ValueNotifier<int> playersAliveNotifier = ValueNotifier(AppConstants.maxPlayers);
  final ValueNotifier<double> zoneTimerNotifier = ValueNotifier(AppConstants.zoneShrinkDuration);
  final ValueNotifier<String> currentWeaponNotifier = ValueNotifier('assault_rifle');
  final ValueNotifier<List<String>> killFeedNotifier = ValueNotifier([]);

  late PlayerComponent localPlayer;
  late ZoneComponent blueZone;
  late NetworkSystem networkSystem;
  late GameTileMap tileMap;

  final List<BotComponent> bots = [];

  IslandRoyaleGame({required this.roomId});

  @override
  Color backgroundColor() => const Color(0xFF1A2A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Camera setup — follow player
    camera.viewfinder.visibleGameSize =
        Vector2(AppConstants.mapWidth.toDouble(), AppConstants.mapHeight.toDouble());

    // Load the tile map
    tileMap = GameTileMap();
    await add(tileMap);

    // Spawn local player in the center
    localPlayer = PlayerComponent(
      position: Vector2(
        AppConstants.mapWidth / 2.0,
        AppConstants.mapHeight / 2.0,
      ),
      isLocal: true,
    );
    await add(localPlayer);

    // Follow local player with camera
    camera.follow(localPlayer);

    // Blue Zone
    blueZone = ZoneComponent(game: this);
    await add(blueZone);

    // Spawn bots
    await _spawnBots(22);

    // Spawn loot items
    await _spawnLoot();

    // Setup networking (connects to server or runs in offline mode)
    networkSystem = NetworkSystem(game: this, roomId: roomId);
    networkSystem.connect();
  }

  Future<void> _spawnBots(int count) async {
    for (int i = 0; i < count; i++) {
      final bot = BotComponent(
        position: Vector2(
          50.0 + (i % 5) * 180.0,
          50.0 + (i ~/ 5) * 180.0,
        ),
        name: 'Bot_${i + 1}',
      );
      bots.add(bot);
      await add(bot);
    }
  }

  Future<void> _spawnLoot() async {
    final lootTypes = ['pistol', 'shotgun', 'assault_rifle', 'sniper',
                       'bandage', 'medkit', 'ammo', 'armor'];
    for (int i = 0; i < 40; i++) {
      final lootType = lootTypes[i % lootTypes.length];
      final item = ItemComponent(
        position: Vector2(
          100.0 + (i * 23.0) % (AppConstants.mapWidth - 200),
          100.0 + (i * 37.0) % (AppConstants.mapHeight - 200),
        ),
        itemType: lootType,
      );
      await add(item);
    }
  }

  /// Called by the joystick widget with movement direction (-1.0 to 1.0)
  void onMoveJoystick(Vector2 direction) {
    localPlayer.moveDirection = direction;
  }

  /// Called by the aim joystick widget
  void onAimJoystick(Vector2 direction) {
    localPlayer.aimDirection = direction;
  }

  /// Fire bullet from local player's current position
  void fireBullet() {
    if (ammoNotifier.value <= 0) return;
    ammoNotifier.value--;

    final bullet = BulletComponent(
      position: localPlayer.position.clone(),
      direction: localPlayer.aimDirection.normalized(),
      ownerId: 'local',
      weaponType: currentWeaponNotifier.value,
    );
    add(bullet);
  }

  void recordKill(String victimName) {
    killCountNotifier.value++;
    final feed = List<String>.from(killFeedNotifier.value);
    feed.insert(0, 'You eliminated $victimName');
    if (feed.length > 5) feed.removeLast();
    killFeedNotifier.value = feed;

    playersAliveNotifier.value =
        (playersAliveNotifier.value - 1).clamp(1, AppConstants.maxPlayers);
  }

  void applyDamage(int amount) {
    final newHp = (healthNotifier.value - amount).clamp(0, 100);
    healthNotifier.value = newHp;
    if (newHp <= 0) {
      _handlePlayerDeath();
    }
  }

  void _handlePlayerDeath() {
    localPlayer.die();
    // Notify screens to show death UI
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Zone timer countdown
    if (zoneTimerNotifier.value > 0) {
      zoneTimerNotifier.value =
          (zoneTimerNotifier.value - dt).clamp(0, AppConstants.zoneShrinkDuration);
    }
  }

  @override
  void onRemove() {
    networkSystem.disconnect();
    healthNotifier.dispose();
    armorNotifier.dispose();
    ammoNotifier.dispose();
    killCountNotifier.dispose();
    playersAliveNotifier.dispose();
    zoneTimerNotifier.dispose();
    currentWeaponNotifier.dispose();
    killFeedNotifier.dispose();
    super.onRemove();
  }
}
