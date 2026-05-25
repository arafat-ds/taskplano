import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/utils/date_utils.dart';
import 'package:taskflow/core/widgets/gradient_scaffold.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';
import 'package:taskflow/features/task/presentation/cubit/task_cubit.dart';
import 'package:taskflow/features/task/presentation/cubit/task_state.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        if (state is TaskInitial || state is TaskLoading) {
          return const GradientScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is! TaskLoaded) {
          return GradientScaffold(
            appBar: AppBar(title: const Text('Task')),
            body: const Center(child: Text('Something went wrong.')),
          );
        }
        final task = state.allTasks.where((t) => t.id == taskId).firstOrNull;
        if (task == null) {
          return GradientScaffold(
            appBar: AppBar(title: const Text('Task')),
            body: const Center(child: Text('Task not found.')),
          );
        }
        return _TaskDetailView(task: task);
      },
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  final TaskEntity task;
  const _TaskDetailView({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOverdue = task.dueDate != null &&
        !task.isCompleted &&
        AppDateUtils.isOverdue(task.dueDate!);

    return GradientScaffold(
      extendBodyBehindAppBar: true,
      appBar: _DetailAppBar(task: task, isDark: isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space for glass AppBar
            const SizedBox(height: 100),

            // ── Glass card ─────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white.withOpacity(0.9),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      _StatusBadge(
                          isCompleted: task.isCompleted,
                          isOverdue: isOverdue),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        task.title,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor:
                              colorScheme.onSurface.withOpacity(0.3),
                          color: task.isCompleted
                              ? colorScheme.onSurface.withOpacity(0.4)
                              : colorScheme.onSurface,
                        ),
                      ),

                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          task.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            height: 1.6,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Divider(
                          color: colorScheme.outline.withOpacity(0.15)),
                      const SizedBox(height: 16),

                      // Meta
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created',
                        value: AppDateUtils.formatDateTime(task.createdAt),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 10),
                        _MetaRow(
                          icon: isOverdue
                              ? Icons.event_busy_outlined
                              : Icons.event_outlined,
                          label: 'Due',
                          value: AppDateUtils.relativeDate(task.dueDate!),
                          valueColor:
                              isOverdue ? const Color(0xFFEF4444) : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Toggle button ──────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                context.read<TaskCubit>().toggleTask(task);
                context.pop();
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: task.isCompleted
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: task.isCompleted
                      ? colorScheme.surfaceContainerHighest
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: task.isCompleted
                      ? []
                      : [
                          BoxShadow(
                            color:
                                const Color(0xFF4F46E5).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.undo_rounded
                          : Icons.check_circle_outline_rounded,
                      color: task.isCompleted
                          ? colorScheme.onSurfaceVariant
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      task.isCompleted
                          ? 'Mark as Pending'
                          : 'Mark as Complete',
                      style: TextStyle(
                        color: task.isCompleted
                            ? colorScheme.onSurfaceVariant
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text(
            'This action cannot be undone. The task will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskCubit>().removeTask(task.id);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Glass AppBar for detail ───────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TaskEntity task;
  final bool isDark;
  const _DetailAppBar({required this.task, required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height + topPadding,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.72),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  'Task Detail',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.ios_share_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 22),
                tooltip: 'Share',
                onPressed: () =>
                    context.read<TaskCubit>().shareTask(task),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444), size: 22),
                tooltip: 'Delete',
                onPressed: () => _confirmDeleteFromAppBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteFromAppBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskCubit>().removeTask(task.id);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isOverdue;
  const _StatusBadge({required this.isCompleted, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    if (isCompleted) {
      bg = const Color(0xFF10B981).withOpacity(0.12);
      fg = const Color(0xFF10B981);
      label = 'Completed';
      icon = Icons.check_circle_outline_rounded;
    } else if (isOverdue) {
      bg = const Color(0xFFEF4444).withOpacity(0.12);
      fg = const Color(0xFFEF4444);
      label = 'Overdue';
      icon = Icons.warning_amber_rounded;
    } else {
      bg = const Color(0xFF4F46E5).withOpacity(0.10);
      fg = const Color(0xFF4F46E5);
      label = 'Pending';
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
