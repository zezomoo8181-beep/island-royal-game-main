import 'package:go_router/go_router.dart';
import 'package:island_royale/screens/main_menu_screen.dart';
import 'package:island_royale/screens/game_screen.dart';
import 'package:island_royale/screens/lobby_screen.dart';
import 'package:island_royale/screens/settings_screen.dart';
import 'package:island_royale/screens/leaderboard_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/lobby',
        builder: (context, state) => const LobbyScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
          final roomId = state.uri.queryParameters['roomId'] ?? 'local';
          return GameScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
}
