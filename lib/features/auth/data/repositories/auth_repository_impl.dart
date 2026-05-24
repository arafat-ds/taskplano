import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failures.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// AuthRepositoryImpl is the single implementation of [AuthRepository].
///
/// Strategy:
///   - All auth operations (signUp, login, logout) go through the REMOTE
///     datasource (Supabase Auth) — the source of truth for identity.
///   - After a successful login/signUp, the user model is cached locally
///     in Hive so [getCurrentUser] can restore the session synchronously
///     on cold start without a network round-trip.
///   - On logout, the local cache is cleared alongside the remote session.
///
/// Error handling:
///   - [AuthException]   → [AuthFailure]
///   - [ServerException] → [ServerFailure]
///   - [CacheException]  → [CacheFailure]
///   - Any other error   → [UnexpectedFailure]
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  const AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  // ── Sign Up ──────────────────────────────────────────────────────────────

  @override
  Future<Result<UserEntity>> signUp(String email, String password) async {
    try {
      final model = await remoteDatasource.signUp(email, password);

      // Only cache locally when a real session was created.
      // If email confirmation is pending (id is empty), skip caching —
      // the user hasn't authenticated yet.
      if (model.id.isNotEmpty) {
        await localDatasource.cacheUser(model);
      }

      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Sign up failed: $e'));
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final model = await remoteDatasource.login(email, password);
      // Cache the authenticated user for session restoration on next launch.
      await localDatasource.cacheUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      // Remote auth succeeded but local cache failed — still return success.
      // The user is authenticated; the cache miss is non-fatal.
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Login failed: $e'));
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> logout() async {
    try {
      // Sign out from Supabase first — if this fails, keep the local cache
      // so the user isn't stuck in a broken state.
      await remoteDatasource.logout();
      await localDatasource.clearUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Logout failed: $e'));
    }
  }

  // ── Get current user ─────────────────────────────────────────────────────

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      // Prefer the live Supabase session — it validates the JWT and handles
      // token refresh automatically. Fall back to the local cache only if
      // the remote call throws (e.g., no network on cold start).
      final model = await remoteDatasource.getCurrentUser();
      if (model != null) {
        // Keep local cache in sync.
        await localDatasource.cacheUser(model);
        return Right(model.toEntity());
      }
      // No active Supabase session — clear stale local cache.
      await localDatasource.clearUser();
      return const Right(null);
    } on ServerException {
      // Network unavailable — fall back to local cache.
      try {
        final cached = await localDatasource.getCachedUser();
        return Right(cached?.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get current user: $e'));
    }
  }
}
