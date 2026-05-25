import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/domain/usecases/create_task.dart';
import 'package:taskflow/features/task/domain/usecases/delete_task.dart';
import 'package:taskflow/features/task/domain/usecases/get_all_tasks.dart';
import 'package:taskflow/features/task/domain/usecases/update_task.dart';
import 'package:taskflow/features/task/presentation/cubit/task_state.dart';

/// TaskCubit bridges the UI and the domain layer.
///
/// ── Optimistic update strategy ────────────────────────────────────────────
/// For toggle, edit, and delete:
///   1. Capture the current [TaskLoaded] state as a rollback snapshot.
///   2. Apply the change locally and emit immediately (instant UI feedback).
///   3. Call the Supabase use case in the background.
///   4a. Success → emit [TaskActionSuccess] then reload from Supabase.
///   4b. Failure → emit [TaskError] then restore the rollback snapshot.
///
/// For create:
///   We add a temporary placeholder task with a local id, then replace it
///   with the Supabase-assigned UUID after the insert succeeds.
///
/// ── Share feature ─────────────────────────────────────────────────────────
/// [shareTask] formats a task into a human-readable string and opens the
/// native share sheet via share_plus.
class TaskCubit extends Cubit<TaskState> {
  final GetAllTasks _getAllTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

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

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Fetches all tasks from Supabase and emits [TaskLoaded] or [TaskError].
  Future<void> loadTasks() async {
    emit(const TaskLoading());
    final result = await _getAllTasks();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => _emitLoaded(tasks),
    );
  }

  // ── Create ────────────────────────────────────────────────────────────────

  /// Adds a new task with an optimistic placeholder, then confirms via Supabase.
  Future<void> addTask(TaskEntity task) async {
    // Snapshot for rollback.
    final snapshot = _currentLoaded;

    // 1. Optimistic: add placeholder immediately.
    if (snapshot != null) {
      _emitLoaded([task, ...snapshot.allTasks], syncing: true);
    }

    final result = await _createTask(task);
    result.fold(
      (failure) {
        // Rollback: restore previous list.
        if (snapshot != null) emit(snapshot);
        emit(TaskError(failure.message));
      },
      (_) async {
        // Reload to get the Supabase-assigned UUID and server timestamps.
        await _reloadSilently();
      },
    );
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  /// Toggles completion status with optimistic update + rollback on failure.
  Future<void> toggleTask(TaskEntity task) async {
    final snapshot = _currentLoaded;
    final toggled = task.copyWith(isCompleted: !task.isCompleted);

    // 1. Optimistic: swap the task in the list immediately.
    if (snapshot != null) {
      final optimistic = snapshot.allTasks
          .map((t) => t.id == task.id ? toggled : t)
          .toList();
      _emitLoaded(optimistic, syncing: true);
    }

    final result = await _updateTask(toggled);
    result.fold(
      (failure) {
        if (snapshot != null) emit(snapshot);
        emit(TaskError(failure.message));
      },
      (_) async {
        await _reloadSilently();
      },
    );
  }

  // ── Edit ──────────────────────────────────────────────────────────────────

  /// Replaces a task with updated data, optimistic update + rollback.
  Future<void> editTask(TaskEntity task) async {
    final snapshot = _currentLoaded;

    if (snapshot != null) {
      final optimistic =
          snapshot.allTasks.map((t) => t.id == task.id ? task : t).toList();
      _emitLoaded(optimistic, syncing: true);
    }

    final result = await _updateTask(task);
    result.fold(
      (failure) {
        if (snapshot != null) emit(snapshot);
        emit(TaskError(failure.message));
      },
      (_) async {
        await _reloadSilently();
      },
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Removes a task optimistically, rolls back on failure.
  Future<void> removeTask(String id) async {
    final snapshot = _currentLoaded;

    if (snapshot != null) {
      final optimistic =
          snapshot.allTasks.where((t) => t.id != id).toList();
      _emitLoaded(optimistic, syncing: true);
    }

    final result = await _deleteTask(id);
    result.fold(
      (failure) {
        if (snapshot != null) emit(snapshot);
        emit(TaskError(failure.message));
      },
      (_) async {
        await _reloadSilently();
      },
    );
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  /// Changes the active filter tab without hitting the repository.
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    final current = _currentLoaded;
    if (current != null) _emitLoaded(current.allTasks);
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  /// Opens the native share sheet with a formatted task summary.
  ///
  /// Format:
  ///   📋 Task: <title>
  ///   📝 Description: <description>
  ///   📅 Due: <due date or 'No due date'>
  ///   ✅ Status: <Active / Completed>
  ///
  ///   Shared from TaskPlano 🚀
  Future<void> shareTask(TaskEntity task) async {
    final status = task.isCompleted ? '✅ Completed' : '🔵 Active';
    final due = task.dueDate != null
        ? '📅 Due: ${_formatDate(task.dueDate!)}'
        : '📅 Due: No due date';

    final text = '''
📋 Task: ${task.title}
${task.description.isNotEmpty ? '📝 ${task.description}\n' : ''}$due
$status

Shared from TaskPlano 🚀''';

    await Share.share(text.trim());
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Returns the current [TaskLoaded] state, or null if not loaded.
  TaskLoaded? get _currentLoaded {
    final s = state;
    return s is TaskLoaded ? s : null;
  }

  /// Reloads from Supabase without emitting a full [TaskLoading] state,
  /// so the list doesn't flash to a spinner during background syncs.
  Future<void> _reloadSilently() async {
    final result = await _getAllTasks();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => _emitLoaded(tasks),
    );
  }

  /// Sorts [tasks], applies [_currentFilter], and emits [TaskLoaded].
  void _emitLoaded(List<TaskEntity> tasks, {bool syncing = false}) {
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
      isSyncing: syncing,
    ));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
