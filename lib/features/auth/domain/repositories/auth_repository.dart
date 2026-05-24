import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/shared/models/result.dart';

/// AuthRepository defines the contract for all authentication operations.
///
/// The domain layer depends ONLY on this abstract class — never on Supabase,
/// Hive, or any framework. This is the Dependency Inversion Principle.
abstract class AuthRepository {
  /// Signs up a new user with [email] and [password].
  ///
  /// Returns the created [UserEntity] on success.
  /// Supabase may require email confirmation — callers should handle
  /// [AuthSignUpSuccess] state to show a "check your email" message.
  Future<Result<UserEntity>> signUp(String email, String password);

  /// Logs in an existing user with [email] and [password].
  Future<Result<UserEntity>> login(String email, String password);

  /// Logs out the currently authenticated user and clears the session.
  Future<Result<void>> logout();

  /// Returns the currently authenticated user, or null if no session exists.
  ///
  /// Used on app startup to restore a persisted session.
  Future<Result<UserEntity?>> getCurrentUser();
}
