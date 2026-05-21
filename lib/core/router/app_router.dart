import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/providers/preloading_provider.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/screens/main_wrapper_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/stats_screen.dart';
import '../../presentation/screens/calendar_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/user_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final preloadingCompleted = ref.watch(preloadingCompletedProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable:
        GoRouterRefreshStream(ref.read(authRepositoryProvider).authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnAuth = state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';
      final isOnWelcome = state.uri.toString() == '/welcome';

      if (!isLoggedIn) {
        if (!isOnAuth) return '/login';
        return null;
      }

      // User is logged in
      if (!preloadingCompleted) {
        if (!isOnWelcome) return '/welcome';
        return null;
      }

      // User is logged in & preloading completed
      if (isOnAuth || isOnWelcome) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'user/:uid',
                    builder: (context, state) => UserProfileScreen(
                      userId: state.pathParameters['uid']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
