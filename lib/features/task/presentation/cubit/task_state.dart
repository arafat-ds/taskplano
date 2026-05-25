import 'package:equatable/equatable.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';

// ── Filter enum ───────────────────────────────────────────────────────────────

/// Controls which subset of tasks is shown in the list.
enum TaskFilter { all, active, completed }

// ── States ────────────────────────────────────────────────────────────────────

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// App just launched, nothing loaded yet.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Initial full-screen load (no tasks in memory yet).
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks loaded successfully.
///
/// [allTasks]      — full unfiltered list (used for stats + detail lookup).
/// [filteredTasks] — subset shown based on [filter].
/// [filter]        — the active filter tab.
/// [isSyncing]     — true while an optimistic write is in-flight.
///                   The UI can show a subtle indicator without blocking.
class TaskLoaded extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskFilter filter;
  final bool isSyncing;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.filter,
    this.isSyncing = false,
  });

  int get totalCount => allTasks.length;
  int get completedCount => allTasks.where((t) => t.isCompleted).length;
  int get activeCount => allTasks.where((t) => !t.isCompleted).length;

  TaskLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskFilter? filter,
    bool? isSyncing,
  }) =>
      TaskLoaded(
        allTasks: allTasks ?? this.allTasks,
        filteredTasks: filteredTasks ?? this.filteredTasks,
        filter: filter ?? this.filter,
        isSyncing: isSyncing ?? this.isSyncing,
      );

  @override
  List<Object?> get props => [allTasks, filteredTasks, filter, isSyncing];
}

/// An operation failed — [message] is shown to the user.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful write so the UI can show a snackbar.
/// The cubit immediately follows this with a [TaskLoaded] state.
class TaskActionSuccess extends TaskState {
  final String message;

  const TaskActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
