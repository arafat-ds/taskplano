import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/services/hive_service.dart';
import 'package:taskflow/core/services/supabase_service.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/usecases/login_user.dart';
import 'package:taskflow/features/auth/domain/usecases/logout_user.dart';
import 'package:taskflow/features/auth/domain/usecases/signup_user.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taskflow/features/task/data/datasources/task_local_datasource.dart';
import 'package:taskflow/features/task/data/repositories/task_repository_impl.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/features/task/domain/usecases/create_task.dart';
import 'package:taskflow/features/task/domain/usecases/delete_task.dart';
import 'package:taskflow/features/task/domain/usecases/get_all_tasks.dart';
import 'package:taskflow/features/task/domain/usecases/update_task.dart';
import 'package:taskflow/features/task/presentation/cubit/task_cubit.dart';

/// sl is the global GetIt service locator.
/// All dependencies are registered here and resolved throughout the app.
final sl = GetIt.instance;

Future<void> init() async {
  // ── 1. External: Supabase ─────────────────────────────────────────────────
  // SupabaseService.initialize() is called in main() before di.init(), so
  // the client is ready here. Registered as a singleton so datasources and
  // AuthCubit receive the same instance via constructor injection.
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseService.client);

  // ── 2. External: Hive ─────────────────────────────────────────────────────
  await HiveService.init();

  final authBox =
      await HiveService.openBox<UserModel>(AppConstants.authBoxName);
  final onboardingBox =
      await HiveService.openBox<dynamic>(AppConstants.onboardingBoxName);

  sl.registerSingleton<Box<UserModel>>(authBox);
  sl.registerSingleton<Box<dynamic>>(onboardingBox,
      instanceName: 'onboardingBox');

  // ── 3. Data Sources ───────────────────────────────────────────────────────

  // Task: in-memory store — swap to TaskHiveDatasource when Hive is ready.
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskInMemoryDatasource(),
  );

  // Auth remote: Supabase Auth — the source of truth for identity.
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(client: sl()),
  );

  // Auth local: Hive-backed session cache for offline restoration.
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(box: sl()),
  );

  // ── 4. Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDatasource: sl()),
  );

  // AuthRepositoryImpl receives BOTH remote and local datasources.
  // Remote handles all auth operations; local caches the session.
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  // ── 5. Use Cases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  sl.registerLazySingleton(() => SignUpUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  // ── 6. Cubits ─────────────────────────────────────────────────────────────

  // TaskCubit — factory (fresh instance per BlocProvider).
  sl.registerFactory(
    () => TaskCubit(
      getAllTasks: sl(),
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );

  // ProfileCubit — factory (no repository dependency; reads from AuthCubit).
  sl.registerFactory(() => ProfileCubit());

  // AuthCubit — lazySingleton so AppRouter's _AuthNotifier and
  // MultiBlocProvider share the exact same instance.
  // SupabaseClient is injected so AuthCubit can subscribe to the
  // onAuthStateChange stream for real-time session sync.
  sl.registerLazySingleton(
    () => AuthCubit(
      signUpUserUseCase: sl(),
      loginUserUseCase: sl(),
      logoutUserUseCase: sl(),
      authRepository: sl(),
      supabaseClient: sl(),
    ),
  );

  // OnboardingCubit — lazySingleton (same reason as AuthCubit).
  sl.registerLazySingleton(
    () => OnboardingCubit(sl(instanceName: 'onboardingBox')),
  );

  // ── 7. Router ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(authCubit: sl(), onboardingCubit: sl()),
  );

  // ── 8. Theme ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ThemeCubit());
}
