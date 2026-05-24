import 'package:hive/hive.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

/// AuthLocalDatasource manages the Hive-backed user session cache.
///
/// Responsibilities:
///   - Persist the authenticated [UserModel] after a successful login/signUp.
///   - Retrieve the cached user on cold start (offline session restoration).
///   - Clear the cache on logout.
///
/// This datasource does NOT perform any authentication — it is purely a
/// local persistence layer. All auth operations go through
/// [AuthRemoteDatasource] (Supabase).
abstract class AuthLocalDatasource {
  /// Persists [model] to the local Hive box.
  Future<void> cacheUser(UserModel model);

  /// Returns the cached [UserModel], or null if no user is stored.
  Future<UserModel?> getCachedUser();

  /// Removes the cached user from the local Hive box.
  Future<void> clearUser();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final Box<UserModel> box;

  const AuthLocalDatasourceImpl({required this.box});

  static const String _currentUserKey = 'current_user';

  @override
  Future<void> cacheUser(UserModel model) async {
    try {
      await box.put(_currentUserKey, model);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      return box.get(_currentUserKey);
    } catch (e) {
      throw CacheException('Failed to read cached user: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await box.delete(_currentUserKey);
    } catch (e) {
      throw CacheException('Failed to clear user cache: $e');
    }
  }
}
