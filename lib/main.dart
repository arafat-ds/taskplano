import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/services/supabase_service.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';
import 'package:taskflow/core/theme/theme_state.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taskflow/features/task/presentation/cubit/task_cubit.dart';
import 'package:taskflow/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Supabase ────────────────────────────────────────────────────────────
  // Must be initialised before di.init() so the SupabaseClient singleton is
  // available when datasources and repositories are registered.
  await SupabaseService.initialize();

  // ── 2. Dependency injection ────────────────────────────────────────────────
  // Registers Hive boxes, datasources, repositories, use cases, cubits, router.
  await di.init();

  // ── 3. Auth state ──────────────────────────────────────────────────────────
  // Trigger auth check before the first frame so GoRouter's redirect guard
  // has a real state (Authenticated / Unauthenticated) immediately.
  await di.sl<AuthCubit>().checkAuthStatus();

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ── Singletons (shared with AppRouter redirect guard) ──────────────
        BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()),
        BlocProvider<OnboardingCubit>(create: (_) => di.sl<OnboardingCubit>()),

        // ── Singleton (shared across all screens) ──────────────────────────
        // ThemeCubit must be a singleton so toggling from any screen updates
        // the MaterialApp.router at the root.
        BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>()),

        // ── Factories (fresh instance per navigation) ──────────────────────
        BlocProvider<TaskCubit>(create: (_) => di.sl<TaskCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => di.sl<ProfileCubit>()),
      ],
      // BlocBuilder<ThemeCubit> wraps MaterialApp.router so the entire app
      // rebuilds with the new ThemeMode the instant the cubit emits.
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'TaskPlano',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            // Driven by ThemeCubit — updates instantly on toggle.
            themeMode: themeState.themeMode,
            routerConfig: di.sl<AppRouter>().router,
          );
        },
      ),
    );
  }
}
