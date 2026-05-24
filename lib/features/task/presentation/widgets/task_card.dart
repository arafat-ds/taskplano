import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taskflow/core/utils/date_utils.dart';
import 'package:taskflow/features/task/domain/entities/task_entity.dart';

/// TaskCard — premium glassmorphism card with animated checkbox.
///
/// Pure presentational widget: receives data + callbacks, owns no state
/// except the local checkbox animation.
class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.task.isCompleted ? 1.0 : 0.0,
    );
    _checkScale = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: _checkCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      widget.task.isCompleted ? _checkCtrl.forward() : _checkCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _handleToggle() {
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOverdue = widget.task.dueDate != null &&
        !widget.task.isCompleted &&
        AppDateUtils.isOverdue(widget.task.dueDate!);

    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(isDark: isDark),
      onDismissed: (_) => widget.onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: widget.task.isCompleted
                    ? (isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white.withOpacity(0.45))
                    : (isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white.withOpacity(0.72)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.task.isCompleted
                      ? (isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.04))
                      : (isDark
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white.withOpacity(0.9)),
                ),
                boxShadow: widget.task.isCompleted
                    ? []
                    : [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.25)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: colorScheme.primary.withOpacity(0.06),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Animated checkbox ──────────────────────────────
                        GestureDetector(
                          onTap: _handleToggle,
                          child: ScaleTransition(
                            scale: _checkScale,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.task.isCompleted
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: widget.task.isCompleted
                                        ? const Color(0xFF10B981)
                                        : colorScheme.outline
                                            .withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: widget.task.isCompleted
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        // ── Content ────────────────────────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: widget.task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: colorScheme.onSurface
                                        .withOpacity(0.3),
                                    color: widget.task.isCompleted
                                        ? colorScheme.onSurface
                                            .withOpacity(0.35)
                                        : colorScheme.onSurface,
                                  ),
                                  child: Text(
                                    widget.task.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Description
                                if (widget.task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(widget.task.isCompleted
                                              ? 0.25
                                              : 0.55),
                                      height: 1.4,
                                    ),
                                  ),
                                ],

                                // Due date chip
                                if (widget.task.dueDate != null) ...[
                                  const SizedBox(height: 8),
                                  _DueDateChip(
                                    date: widget.task.dueDate!,
                                    isOverdue: isOverdue,
                                    isCompleted: widget.task.isCompleted,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // ── Chevron ────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 6),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Delete swipe background ───────────────────────────────────────────────────

class _DeleteBackground extends StatelessWidget {
  final bool isDark;
  const _DeleteBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          SizedBox(height: 2),
          Text(
            'Delete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Due date chip ─────────────────────────────────────────────────────────────

class _DueDateChip extends StatelessWidget {
  final DateTime date;
  final bool isOverdue;
  final bool isCompleted;

  const _DueDateChip({
    required this.date,
    required this.isOverdue,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;

    if (isCompleted) {
      bg = Colors.grey.withOpacity(0.12);
      fg = Colors.grey;
      icon = Icons.event_available_outlined;
    } else if (isOverdue) {
      bg = const Color(0xFFEF4444).withOpacity(0.12);
      fg = const Color(0xFFEF4444);
      icon = Icons.event_busy_outlined;
    } else {
      bg = const Color(0xFF4F46E5).withOpacity(0.10);
      fg = const Color(0xFF4F46E5);
      icon = Icons.event_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            AppDateUtils.relativeDate(date),
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
