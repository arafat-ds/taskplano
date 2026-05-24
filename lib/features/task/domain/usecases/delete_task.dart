import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// DeleteTask use case removes a task by its ID via the repository.
class DeleteTask {
  final TaskRepository repository;

  const DeleteTask(this.repository);

  Future<Result<void>> call(String id) {
    return repository.deleteTask(id);
  }
}
