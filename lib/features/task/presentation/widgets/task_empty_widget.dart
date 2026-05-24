import 'package:flutter/material.dart';
import 'package:taskflow/features/task/presentation/cubit/task_state.dart';

/// TaskEmptyWidget — premium animated empty state.
class TaskEmptyWidget extends StatefulWidget {
  final TaskFilter filter;
  final VoidCallback onAddTask;

  const TaskEmptyWidget({
    super.key,
    required this.filter,
    required this.onAddTask,
  });

  @override
  State<TaskEmptyWidget> createState() => _TaskEmptyWidgetState();
}

class _TaskEmptyWidgetState extends State<TaskEmptyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _iconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (IconData icon, String title, String subtitle, Color accent) =
        switch (widget.filter) {
      TaskFilter.all => (
          Icons.rocket_launch_rounded,
          'Ready to plan?',
          'Your productivity journey starts here.\nTap below to add your first task.',
          const Color(0xFF4F46E5),
        ),
      TaskFilter.active => (
          Icons.celebration_rounded,
          'All caught up!',
          'No pending tasks. Enjoy the moment\nor add something new.',
          const Color(0xFF10B981),
        ),
      TaskFilter.completed => (
          Icons.emoji_events_rounded,
          'Nothing here yet',
          'Complete a task and it will\nappear in this list.',
          const Color(0xFFF59E0B),
        ),
    };

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated icon orb ──────────────────────────────────────
                ScaleTransition(
                  scale: _iconScale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withOpacity(isDark ? 0.25 : 0.15),
                          accent.withOpacity(0.0),
                        ],
                      ),
                      border: Border.all(
                        color: accent.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, size: 52, color: accent),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // ── Subtitle ───────────────────────────────────────────────
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                // ── CTA ────────────────────────────────────────────────────
                if (widget.filter == TaskFilter.all) ...[
                  const SizedBox(height: 36),
                  GestureDetector(
                    onTap: widget.onAddTask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add your first task',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
