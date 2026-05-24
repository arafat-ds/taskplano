import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

/// AuthRemoteDatasource handles all Supabase Auth API calls.
///
/// This is the ONLY class that knows about Supabase Auth.
/// If we ever swap Supabase for Firebase or a custom backend, only this
/// file changes — nothing above it needs to know.
///
/// Every method either returns a [UserModel] or throws a typed exception
/// that the repository converts into a domain [Failure].
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

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      // Supabase returns a null user when email confirmation is required
      // and the account does not yet have a confirmed session.
      // We return a placeholder model so the cubit can emit the correct state.
      if (user == null) {
        return UserModel(
          id: '',
          name: email.split('@').first,
          email: email,
          needsEmailConfirmation: true,
        );
      }

      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            email.split('@').first,
        email: user.email ?? email,
        // No session means Supabase sent a confirmation email.
        needsEmailConfirmation: response.session == null,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(_mapSupabaseError(e.message));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Sign up failed: $e');
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Login failed. Please try again.');
      }

      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            email.split('@').first,
        email: user.email ?? email,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(_mapSupabaseError(e.message));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Login failed: $e');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException('Logout failed: $e');
    }
  }

  // ── Get current user ─────────────────────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.id,
        name: user.userMetadata?['name'] as String? ??
            (user.email?.split('@').first ?? 'User'),
        email: user.email ?? '',
      );
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  /// Converts Supabase error messages into user-friendly strings.
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
        lower.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
    }
    if (lower.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    return message;
  }
}
