import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failures.dart';
import 'package:taskflow/features/task/data/datasources/task_remote_datasource.dart';
import 'package:taskflow/features/task/data/models/task_model.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// TaskRepositoryImpl bridges the remote datasource and the domain layer.
///
/// All operations go through [TaskRemoteDatasource] (Supabase).
/// Exceptions are caught here and converted into typed [Failure] objects
/// so the domain layer never sees raw exceptions.
///
/// Error mapping:
///   [ServerException]   → [ServerFailure]
///   [NotFoundException] → [NotFoundFailure]
///   Any other           → [UnexpectedFailure]
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource remoteDatasource;

  const TaskRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Result<List<TaskEntity>>> getAllTasks() async {
    try {
      final models = await remoteDatasource.getAllTasks();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to load tasks: $e'));
    }
  }

  @override
  Future<Result<TaskEntity>> createTask(TaskEntity task) async {
    try {
      final saved =
          await remoteDatasource.createTask(TaskModel.fromEntity(task));
      return Right(saved.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create task: $e'));
    }
  }

  @override
  Future<Result<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final updated =
          await remoteDatasource.updateTask(TaskModel.fromEntity(task));
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await remoteDatasource.deleteTask(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete task: $e'));
    }
  }
}
