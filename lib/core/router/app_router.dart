import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow/features/auth/presentation/pages/login_page.dart';
import 'package:taskflow/features/auth/presentation/pages/signup_page.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:taskflow/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:taskflow/features/profile/presentation/pages/profile_page.dart';
import 'package:taskflow/features/task/presentation/pages/task_detail_page.dart';
import 'package:taskflow/features/task/presentation/pages/task_list_page.dart';

/// AppRouter configures all named routes for the application.
///
/// The [_AuthNotifier] bridges [AuthCubit] → [Listenable] so GoRouter's
/// [refreshListenable] re-evaluates the redirect guard on every auth state
/// change — including external events like token expiry or sign-out from
/// another device.
class AppRouter {
  final AuthCubit authCubit;
  final OnboardingCubit onboardingCubit;

  AppRouter({required this.authCubit, required this.onboardingCubit});

  /// Routes that are accessible without authentication.
  static const _publicRoutes = {'/login', '/signup', '/onboarding'};

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,

    // Bridges Cubit state changes to GoRouter's redirect mechanism.
    // Every time AuthCubit emits a new state, GoRouter re-runs [redirect].
    refreshListenable: _AuthNotifier(authCubit),

    // ── Auth redirect guard ────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final isLoading = authState is AuthLoading || authState is AuthInitial;
      final isAuthenticated = authState is AuthAuthenticated;
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // While the initial auth check is running, stay on the current route.
      // This prevents a flash of the login screen on cold start.
      if (isLoading) return null;

      // Show onboarding first if not yet completed.
      if (!onboardingCubit.isCompleted && location != '/onboarding') {
        return '/onboarding';
      }

      // Redirect unauthenticated users to login.
      if (!isAuthenticated && !isPublic) {
        return '/login';
      }

      // Redirect authenticated users away from auth screens.
      if (isAuthenticated &&
          (location == '/login' || location == '/signup')) {
        return '/tasks';
      }

      return null; // No redirect needed.
    },

    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (_, __) => const TaskListPage(),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (_, state) => TaskDetailPage(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfilePage(),
      ),
    ],
  );
}

/// Bridges [AuthCubit] to [ChangeNotifier] so GoRouter can listen to
/// auth state changes via [refreshListenable].
///
/// GoRouter calls [notifyListeners] → re-runs [redirect] → routes update.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthCubit cubit) {
    // Listen to the cubit's stream and notify GoRouter on every emission.
    cubit.stream.listen((_) => notifyListeners());
  }
}
