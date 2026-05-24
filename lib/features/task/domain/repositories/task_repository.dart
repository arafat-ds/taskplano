import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/shared/models/result.dart';

/// TaskRepository defines the contract (interface) for task data operations.
///
/// The domain layer depends ONLY on this abstract class — never on the
/// concrete implementation. This is the Dependency Inversion Principle.
///
/// The implementation lives in the data layer (task_repository_impl.dart).
abstract class TaskRepository {
  /// Returns all tasks stored locally.
  Future<Result<List<TaskEntity>>> getAllTasks();

  /// Persists a new task and returns the saved entity.
  Future<Result<TaskEntity>> createTask(TaskEntity task);

  /// Updates an existing task and returns the updated entity.
  Future<Result<TaskEntity>> updateTask(TaskEntity task);

  /// Deletes the task with the given [id].
  Future<Result<void>> deleteTask(String id);
}
