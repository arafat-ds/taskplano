import 'package:equatable/equatable.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';

// ── Filter enum ───────────────────────────────────────────────────────────────
/// Controls which subset of tasks is shown in the list.
enum TaskFilter { all, active, completed }

// ── States ────────────────────────────────────────────────────────────────────

/// Base class — all task states extend this.
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// App just launched, nothing loaded yet.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// A load or write operation is in progress.
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks loaded successfully.
///
/// [allTasks]      — the full unfiltered list (used for stats).
/// [filteredTasks] — the subset currently shown based on [filter].
/// [filter]        — the active filter tab.
class TaskLoaded extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskFilter filter;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.filter,
  });

  // Convenience getters used by the stats header.
  int get totalCount => allTasks.length;
  int get completedCount => allTasks.where((t) => t.isCompleted).length;
  int get activeCount => allTasks.where((t) => !t.isCompleted).length;

  @override
  List<Object?> get props => [allTasks, filteredTasks, filter];
}

/// An operation failed — [message] is shown to the user.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
