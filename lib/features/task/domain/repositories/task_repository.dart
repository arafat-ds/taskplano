import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/shared/models/result.dart';

/// TaskRepository defines the contract for all task data operations.
///
/// The domain layer depends ONLY on this abstract class — never on Supabase,
/// Hive, or any framework. This is the Dependency Inversion Principle.
abstract class TaskRepository {
  /// Returns all tasks for the current authenticated user.
  Future<Result<List<TaskEntity>>> getAllTasks();

  /// Persists a new task to Supabase and returns the saved entity.
  Future<Result<TaskEntity>> createTask(TaskEntity task);

  /// Updates an existing task in Supabase and returns the updated entity.
  Future<Result<TaskEntity>> updateTask(TaskEntity task);

  /// Deletes the task with the given [id] from Supabase.
  Future<Result<void>> deleteTask(String id);
}
