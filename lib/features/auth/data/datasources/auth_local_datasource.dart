import 'package:hive/hive.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

/// AuthLocalDatasource handles persisting and reading auth state from Hive.
///
/// For this starter, login is simulated locally (no real server).
/// Swap this datasource for a remote one when a backend is added.
abstract class AuthLocalDatasource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final Box<UserModel> box;

  const AuthLocalDatasourceImpl({required this.box});

  static const String _currentUserKey = 'current_user';

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // ── Simulated local auth ─────────────────────────────────────────────
      // In a real app, validate credentials against a remote API here.
      // For now, any non-empty email/password creates a local session.
      final user = UserModel(
        id: email.hashCode.abs().toString(),
        name: email.split('@').first,
        email: email,
      );
      await box.put(_currentUserKey, user);
      return user;
    } catch (e) {
      throw CacheException('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await box.delete(_currentUserKey);
    } catch (e) {
      throw CacheException('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return box.get(_currentUserKey);
    } catch (e) {
      throw CacheException('Failed to get current user: $e');
    }
  }
}
