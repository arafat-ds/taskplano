import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow/features/auth/presentation/pages/login_page.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:taskflow/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:taskflow/features/profile/presentation/pages/profile_page.dart';
import 'package:taskflow/features/task/presentation/pages/task_detail_page.dart';
import 'package:taskflow/features/task/presentation/pages/task_list_page.dart';

/// AppRouter configures all named routes for the application.
///
/// GoRouter's [redirect] guard checks auth state before every navigation,
/// ensuring unauthenticated users are always sent to /login.
class AppRouter {
  final AuthCubit authCubit;
  final OnboardingCubit onboardingCubit;

  AppRouter({required this.authCubit, required this.onboardingCubit});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,

    // ── Auth redirect guard ────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Show onboarding first if not yet completed.
      if (!onboardingCubit.isCompleted && !isOnOnboarding) {
        return '/onboarding';
      }

      // Redirect unauthenticated users to login.
      if (!isAuthenticated && !isOnLoginPage && !isOnOnboarding) {
        return '/login';
      }

      // Redirect authenticated users away from login.
      if (isAuthenticated && isOnLoginPage) {
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
