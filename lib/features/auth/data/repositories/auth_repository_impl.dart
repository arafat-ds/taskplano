import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failures.dart';
import 'package:taskflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// AuthRepositoryImpl converts datasource exceptions into domain Failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  const AuthRepositoryImpl({required this.localDatasource});

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final model = await localDatasource.login(email, password);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDatasource.logout();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final model = await localDatasource.getCurrentUser();
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
