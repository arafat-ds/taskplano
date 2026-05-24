import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// UpdateTask use case modifies an existing task via the repository.
class UpdateTask {
  final TaskRepository repository;

  const UpdateTask(this.repository);

  Future<Result<TaskEntity>> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
