import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/usecases/create_task.dart';
import 'package:taskflow/features/task/domain/usecases/delete_task.dart';
import 'package:taskflow/features/task/domain/usecases/get_all_tasks.dart';
import 'package:taskflow/features/task/domain/usecases/update_task.dart';
import 'package:taskflow/features/task/presentation/cubit/task_state.dart';

/// TaskCubit is the bridge between the UI and the domain layer.
///
/// It calls use cases, handles Either<Failure, T> results via fold(), and
/// emits the correct TaskState so widgets rebuild only when needed.
///
/// The UI never calls repositories or datasources directly.
///
/// ── Switching to Hive ────────────────────────────────────────────────────────
/// Nothing in this file changes when Hive is connected. Only the datasource
/// registered in injection_container.dart needs to be swapped.
/// ─────────────────────────────────────────────────────────────────────────────
class TaskCubit extends Cubit<TaskState> {
  final GetAllTasks _getAllTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

  // Active filter — kept in the cubit so it survives state rebuilds.
  TaskFilter _currentFilter = TaskFilter.all;

  TaskCubit({
    required GetAllTasks getAllTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
  })  : _getAllTasks = getAllTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        super(const TaskInitial());

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Loads all tasks from the repository and emits [TaskLoaded] or [TaskError].
  Future<void> loadTasks() async {
    emit(const TaskLoading());
    final result = await _getAllTasks();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => _emitLoaded(tasks),
    );
  }

  /// Creates a new task, then reloads the full list.
  Future<void> addTask(TaskEntity task) async {
    final result = await _createTask(task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  /// Toggles the completion status of a task, then reloads.
  Future<void> toggleTask(TaskEntity task) async {
    final toggled = task.copyWith(isCompleted: !task.isCompleted);
    final result = await _updateTask(toggled);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  /// Replaces a task with updated data, then reloads.
  Future<void> editTask(TaskEntity task) async {
    final result = await _updateTask(task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  /// Deletes a task by ID, then reloads.
  Future<void> removeTask(String id) async {
    final result = await _deleteTask(id);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  /// Changes the active filter tab and re-emits with the filtered list.
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    // Re-apply filter to the current list without hitting the repository.
    final current = state;
    if (current is TaskLoaded) {
      _emitLoaded(current.allTasks);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Sorts [tasks], applies [_currentFilter], and emits [TaskLoaded].
  void _emitLoaded(List<TaskEntity> tasks) {
    // Sort: incomplete first, then newest first within each group.
    final sorted = List<TaskEntity>.from(tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final filtered = switch (_currentFilter) {
      TaskFilter.all => sorted,
      TaskFilter.active => sorted.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => sorted.where((t) => t.isCompleted).toList(),
    };

    emit(TaskLoaded(
      allTasks: sorted,
      filteredTasks: filtered,
      filter: _currentFilter,
    ));
  }
}
