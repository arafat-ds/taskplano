import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// GetAllTasks use case retrieves every task from the repository.
///
/// Use cases contain a single piece of business logic and depend only on
/// the repository interface — never on Hive, HTTP, or Flutter widgets.
class GetAllTasks {
  final TaskRepository repository;

  const GetAllTasks(this.repository);

  /// Executes the use case.
  Future<Result<List<TaskEntity>>> call() {
    return repository.getAllTasks();
  }
}
