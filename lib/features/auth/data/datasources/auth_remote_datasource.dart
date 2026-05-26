import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

/// AuthRemoteDatasource handles all Supabase Auth API calls.
///
/// This is the ONLY class that knows about Supabase Auth.
/// Every method either returns data or throws a typed exception that the
/// repository converts into a domain [Failure].
abstract class AuthRemoteDatasource {
  Future<UserModel> signUp(String email, String password);
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final supa.SupabaseClient client;

  const AuthRemoteDatasourceImpl({required this.client});

  // ── Sign Up ──────────────────────────────────────────────────────────────

  /// Signs up a new user via Supabase Auth.
  ///
  /// Supabase behaviour when "Confirm email" is enabled in the dashboard:
  ///   - [response.user]    is populated with the new user's UUID.
  ///   - [response.session] is NULL — the session only activates after the
  ///     user clicks the confirmation link.
  ///
  /// Supabase behaviour when "Confirm email" is DISABLED:
  ///   - Both [response.user] and [response.session] are populated.
  ///
  /// In both cases the user IS created in Supabase Auth > Users.
  /// We signal "needs confirmation" via [UserModel.needsEmailConfirmation]
  /// so the cubit can emit [AuthSignUpSuccess] instead of [AuthAuthenticated].
  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      debugPrint('[AuthRemote] signUp called for $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      debugPrint('[AuthRemote] signUp response — '
          'user: ${response.user?.id}, '
          'session: ${response.session != null}');

      final user = response.user;

      // user is null only in extremely rare edge cases (e.g. the Supabase
      // project has a custom hook that blocks sign-up). Treat as failure.
      if (user == null) {
        debugPrint('[AuthRemote] signUp: user is null — treating as failure');
        throw AuthException(
          'Sign up failed. Please try again or contact support.',
        );
      }

      // session == null means email confirmation is required.
      // The user EXISTS in Supabase Auth > Users but cannot log in yet.
      final needsConfirmation = response.session == null;
      debugPrint('[AuthRemote] signUp: needsConfirmation=$needsConfirmation');

      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            email.split('@').first,
        email: user.email ?? email,
        needsEmailConfirmation: needsConfirmation,
      );
    } on supa.AuthException catch (e) {
      // Supabase threw a typed auth error (e.g. "User already registered").
      debugPrint('[AuthRemote] signUp AuthException: ${e.message}');
      throw AuthException(_mapSupabaseError(e.message));
    } on AuthException {
      // Our own AuthException from the null-user guard above — rethrow as-is.
      rethrow;
    } catch (e, st) {
      // Unexpected error (network, JSON parse, etc.).
      debugPrint('[AuthRemote] signUp unexpected error: $e\n$st');
      throw ServerException('Sign up failed: $e');
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      debugPrint('[AuthRemote] login called for $email');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Login failed. Please try again.');
      }

      debugPrint('[AuthRemote] login success — user: ${user.id}');

      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            email.split('@').first,
        email: user.email ?? email,
      );
    } on supa.AuthException catch (e) {
      debugPrint('[AuthRemote] login AuthException: ${e.message}');
      throw AuthException(_mapSupabaseError(e.message));
    } on AuthException {
      rethrow;
    } catch (e, st) {
      debugPrint('[AuthRemote] login unexpected error: $e\n$st');
      throw ServerException('Login failed: $e');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
      debugPrint('[AuthRemote] logout success');
    } on supa.AuthException catch (e) {
      debugPrint('[AuthRemote] logout AuthException: ${e.message}');
      throw AuthException(e.message);
    } catch (e, st) {
      debugPrint('[AuthRemote] logout unexpected error: $e\n$st');
      throw ServerException('Logout failed: $e');
    }
  }

  // ── Get current user ─────────────────────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        debugPrint('[AuthRemote] getCurrentUser: no active session');
        return null;
      }

      debugPrint('[AuthRemote] getCurrentUser: ${user.id}');
      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            (user.email?.split('@').first ?? 'User'),
        email: user.email ?? '',
      );
    } catch (e, st) {
      debugPrint('[AuthRemote] getCurrentUser unexpected error: $e\n$st');
      throw ServerException('Failed to get current user: $e');
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  /// Maps Supabase error messages to user-friendly strings.
  /// Falls back to the original message so nothing is silently swallowed.
  String _mapSupabaseError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid email or password')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered') ||
        lower.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('too many requests') ||
        lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
    }
    if (lower.contains('password should be at least') ||
        lower.contains('password must be')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('unable to validate email address') ||
        lower.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('signup is disabled')) {
      return 'New registrations are currently disabled. Please contact support.';
    }

    // Return the raw Supabase message so nothing is hidden from the user.
    return message;
  }
}
