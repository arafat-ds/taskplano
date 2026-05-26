import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:taskflow/features/auth/data/models/user_model.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/usecases/login_user.dart';
import 'package:taskflow/features/auth/domain/usecases/logout_user.dart';
import 'package:taskflow/features/auth/domain/usecases/signup_user.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';

/// AuthCubit manages authentication state for the entire app.
///
/// It is provided at the root of the widget tree so GoRouter's redirect
/// guard can read the current auth state to protect routes.
///
/// It also subscribes to Supabase's [onAuthStateChange] stream so that
/// external events (token refresh, sign-out from another device, deep-link
/// email confirmation) are reflected in the UI without any manual polling.
class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUserUseCase;
  final SignUpUser signUpUserUseCase;
  final LogoutUser logoutUserUseCase;
  final AuthRepository authRepository;
  final supa.SupabaseClient supabaseClient;

  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthCubit({
    required this.loginUserUseCase,
    required this.signUpUserUseCase,
    required this.logoutUserUseCase,
    required this.authRepository,
    required this.supabaseClient,
  }) : super(const AuthInitial());

  // ── Session check ─────────────────────────────────────────────────────────

  /// Called once in main() before runApp.
  ///
  /// Restores a persisted Supabase session (JWT stored by the SDK) and
  /// then subscribes to future auth state changes so the cubit stays in
  /// sync for the lifetime of the app.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );

    // Subscribe AFTER the initial check so we don't double-emit on startup.
    _subscribeToAuthChanges();
  }

  // ── Supabase auth stream ──────────────────────────────────────────────────

  /// Listens to Supabase's auth event stream and keeps the cubit in sync.
  ///
  /// Handles:
  ///   - [AuthChangeEvent.signedIn]  → emit [AuthAuthenticated]
  ///   - [AuthChangeEvent.signedOut] → emit [AuthUnauthenticated]
  ///   - [AuthChangeEvent.tokenRefreshed] → update user entity silently
  ///   - [AuthChangeEvent.userUpdated]    → update user entity silently
  void _subscribeToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = supabaseClient.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;

        switch (event) {
          case supa.AuthChangeEvent.signedIn:
          case supa.AuthChangeEvent.tokenRefreshed:
          case supa.AuthChangeEvent.userUpdated:
            final supaUser = session?.user;
            if (supaUser != null) {
              final user = UserModel(
                id: supaUser.id,
                name: supaUser.userMetadata?['name'] as String? ??
                    (supaUser.email?.split('@').first ?? 'User'),
                email: supaUser.email ?? '',
              ).toEntity();
              emit(AuthAuthenticated(user));
            }

          case supa.AuthChangeEvent.signedOut:
            emit(const AuthUnauthenticated());

          // passwordRecovery, mfaChallengeVerified, etc. — no state change needed.
          default:
            break;
        }
      },
      onError: (_) {
        // Stream error is non-fatal — keep current state.
      },
    );
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Signs up a new user with [email] and [password].
  ///
  /// Emits [AuthSignUpSuccess] when Supabase requires email confirmation
  /// (session is null but user was created — visible in Auth > Users).
  /// Emits [AuthAuthenticated] when email confirmation is disabled and a
  /// session is returned immediately.
  /// Emits [AuthError] on any failure.
  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());
    final result = await signUpUserUseCase(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Use the domain flag — not id.isEmpty — to detect confirmation flow.
        // The user always has a real UUID now; the flag is the correct signal.
        if (user.needsEmailConfirmation) {
          emit(AuthSignUpSuccess(user.email));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Logs in with [email] and [password].
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await loginUserUseCase(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  /// Logs out the current user and clears the Supabase session.
  ///
  /// The [onAuthStateChange] stream will emit [AuthChangeEvent.signedOut]
  /// which also triggers [AuthUnauthenticated], but we emit it here too
  /// for immediate UI feedback before the stream fires.
  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await logoutUserUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  // ── Convenience getter ────────────────────────────────────────────────────

  /// Returns the currently authenticated user entity, or null.
  ///
  /// Safe to call from any widget that has access to the cubit.
  dynamic get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
