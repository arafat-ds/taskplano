import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/usecases/login_user.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';

/// AuthCubit manages authentication state for the entire app.
///
/// It is provided at the root of the widget tree so GoRouter's redirect
/// can read the current auth state to guard routes.
class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUserUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginUserUseCase,
    required this.authRepository,
  }) : super(const AuthInitial());

  /// Checks for an existing session on app start.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  /// Logs in with [email] and [password].
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await loginUserUseCase(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
