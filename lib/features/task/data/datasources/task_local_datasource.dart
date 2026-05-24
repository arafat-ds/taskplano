import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/task/data/models/task_model.dart';

/// TaskLocalDatasource defines the contract for task persistence.
///
/// The abstract class is the boundary — the repository only knows this
/// interface. Swap the implementation (in-memory → Hive → SQLite) without
/// touching anything above this layer.
abstract class TaskLocalDatasource {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> saveTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

/// TaskInMemoryDatasource is a pure in-memory implementation backed by a Map.
///
/// Used during UI development so the app runs without Hive or code generation.
/// Replace with TaskHiveDatasource when persistence is needed.
class TaskInMemoryDatasource implements TaskLocalDatasource {
  // Map<id, TaskModel> — O(1) lookup by id.
  final Map<String, TaskModel> _store = {};

  @override
  Future<List<TaskModel>> getAllTasks() async {
    return _store.values.toList();
  }

  @override
  Future<TaskModel> saveTask(TaskModel task) async {
    if (_store.containsKey(task.id)) {
      throw CacheException('Task with id ${task.id} already exists.');
    }
    _store[task.id] = task;
    return task;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    if (!_store.containsKey(task.id)) {
      throw NotFoundException('Task ${task.id} not found.');
    }
    _store[task.id] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    if (!_store.containsKey(id)) {
      throw NotFoundException('Task $id not found.');
    }
    _store.remove(id);
  }
}
