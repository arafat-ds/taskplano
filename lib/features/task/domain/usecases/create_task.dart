import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/repositories/task_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// CreateTask use case persists a new task via the repository.
class CreateTask {
  final TaskRepository repository;

  const CreateTask(this.repository);

  Future<Result<TaskEntity>> call(TaskEntity task) {
    return repository.createTask(task);
  }
}
