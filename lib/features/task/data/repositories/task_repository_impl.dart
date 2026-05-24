import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failures.dart';
import 'package:taskflow/features/task/data/datasources/task_local_datasource.dart';
import 'package:taskflow/features/task/data/models/task_model.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// TaskRepositoryImpl bridges the datasource and the domain layer.
///
/// Responsibilities:
///   1. Call the datasource.
///   2. Catch datasource exceptions.
///   3. Convert them into typed Failure objects.
///   4. Return Either<Failure, T> — the domain layer never sees raw exceptions.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource localDatasource;

  const TaskRepositoryImpl({required this.localDatasource});

  @override
  Future<Result<List<TaskEntity>>> getAllTasks() async {
    try {
      final models = await localDatasource.getAllTasks();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<TaskEntity>> createTask(TaskEntity task) async {
    try {
      final saved = await localDatasource.saveTask(TaskModel.fromEntity(task));
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final updated =
          await localDatasource.updateTask(TaskModel.fromEntity(task));
      return Right(updated.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await localDatasource.deleteTask(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
