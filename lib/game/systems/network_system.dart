import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:island_royale/game/island_royale_game.dart';
import 'package:island_royale/utils/constants.dart';

/// Handles all real-time multiplayer communication.
/// Heavy JSON decoding happens in a Dart Isolate so the game thread stays fast.
class NetworkSystem {
  final IslandRoyaleGame game;
  final String roomId;

  WebSocketChannel? _channel;
  Timer? _syncTimer;
  bool _connected = false;
  final _log = Logger();

  // Isolate for heavy decoding
  Isolate? _decodeIsolate;
  ReceivePort? _receivePort;

  NetworkSystem({required this.game, required this.roomId});

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${AppConstants.wsUrl}/$roomId'),
      );
      _connected = true;
      _log.i('NetworkSystem: Connected to $roomId');

      // Listen for server messages
      _channel!.stream.listen(
        _onServerMessage,
        onError: (e) {
          _log.w('WS error: $e — switching to offline mode');
          _connected = false;
        },
        onDone: () {
          _log.i('WS closed');
          _connected = false;
        },
      );

      // Start sending local player state
      _startSyncLoop();
    } catch (e) {
      _log.w('Cannot connect to server ($e) — running in offline/bot-only mode');
      _connected = false;
    }
  }

  void _startSyncLoop() {
    _syncTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.syncIntervalMs),
      (_) => _sendLocalState(),
    );
  }

  void _sendLocalState() {
    if (!_connected || _channel == null) return;
    final player = game.localPlayer;
    final msg = jsonEncode({
      'type': 'player_update',
      'roomId': roomId,
      'x': player.position.x,
      'y': player.position.y,
      'aimX': player.aimDirection.x,
      'aimY': player.aimDirection.y,
      'hp': game.healthNotifier.value,
      'weapon': game.currentWeaponNotifier.value,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    _channel!.sink.add(msg);
  }

  void _onServerMessage(dynamic raw) {
    // Offload JSON decode to isolate to avoid jank
    _decodeInBackground(raw.toString());
  }

  Future<void> _decodeInBackground(String raw) async {
    // Simple isolate for heavy decode
    final rp = ReceivePort();
    await Isolate.spawn(_decodeWorker, [rp.sendPort, raw]);
    final result = await rp.first as Map<String, dynamic>?;
    if (result != null) _handleMessage(result);
    rp.close();
  }

  static void _decodeWorker(List<dynamic> args) {
    final SendPort sp = args[0] as SendPort;
    final String raw = args[1] as String;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      sp.send(decoded);
    } catch (_) {
      sp.send(null);
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    switch (type) {
      case 'player_update':
        // Update remote player positions (future: render remote players)
        break;
      case 'player_eliminated':
        final name = msg['name'] as String? ?? 'Unknown';
        final feed = List<String>.from(game.killFeedNotifier.value);
        feed.insert(0, '$name was eliminated');
        if (feed.length > 5) feed.removeLast();
        game.killFeedNotifier.value = feed;
        game.playersAliveNotifier.value =
            (game.playersAliveNotifier.value - 1).clamp(1, AppConstants.maxPlayers);
        break;
      case 'zone_update':
        // Server-authoritative zone radius can override local
        break;
    }
  }

  void sendFireEvent() {
    if (!_connected || _channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'fire',
      'x': game.localPlayer.position.x,
      'y': game.localPlayer.position.y,
      'aimX': game.localPlayer.aimDirection.x,
      'aimY': game.localPlayer.aimDirection.y,
      'weapon': game.currentWeaponNotifier.value,
    }));
  }

  void disconnect() {
    _syncTimer?.cancel();
    _decodeIsolate?.kill();
    _receivePort?.close();
    _channel?.sink.close();
    _connected = false;
  }

  bool get isConnected => _connected;
}
