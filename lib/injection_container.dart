import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/services/hive_service.dart';
import 'package:taskflow/core/services/supabase_service.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/usecases/login_user.dart';
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
  // the client is ready here. Register it as a singleton so any datasource
  // can receive it via constructor injection — no direct Supabase.instance
  // calls outside of SupabaseService.
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseService.client);

  // ── 2. External: Hive (auth + onboarding only) ────────────────────────────
  // Task storage uses in-memory in this phase — no Hive box needed for tasks.
  await HiveService.init();

  final authBox = await HiveService.openBox<UserModel>(AppConstants.authBoxName);
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

  // Auth: Hive-backed
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(box: sl()),
  );

  // ── 4. Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDatasource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDatasource: sl()),
  );

  // ── 5. Use Cases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));

  // ── 6. Cubits ─────────────────────────────────────────────────────────────
  // TaskCubit is a factory — fresh instance per BlocProvider.
  // It is now fully wired to the use cases (Clean Architecture complete).
  // To switch to Hive: only change the TaskLocalDatasource registration above.
  sl.registerFactory(
    () => TaskCubit(
      getAllTasks: sl(),
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );

  sl.registerFactory(() => ProfileCubit(authRepository: sl()));

  // AuthCubit and OnboardingCubit are lazySingletons — AppRouter's redirect
  // guard holds direct references to them, so they must be the same instances
  // that MultiBlocProvider provides to the widget tree.
  sl.registerLazySingleton(
    () => AuthCubit(loginUserUseCase: sl(), authRepository: sl()),
  );
  sl.registerLazySingleton(
    () => OnboardingCubit(sl(instanceName: 'onboardingBox')),
  );

  // ── 6. Router ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(authCubit: sl(), onboardingCubit: sl()),
  );

  // ── 7. Theme ──────────────────────────────────────────────────────────────
  // lazySingleton — one ThemeCubit shared across the entire app.
  sl.registerLazySingleton(() => ThemeCubit());
}
