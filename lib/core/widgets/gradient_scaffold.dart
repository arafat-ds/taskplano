import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_theme.dart';

/// GradientScaffold wraps a standard Scaffold with the brand gradient
/// background so every screen shares the same premium look.
///
/// Usage: replace `Scaffold(...)` with `GradientScaffold(...)`.
/// All Scaffold parameters are forwarded unchanged.
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors =
        isDark ? AppTheme.darkGradient : AppTheme.lightGradient;

    return Stack(
      children: [
        // ── Gradient background ──────────────────────────────────────────
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── Decorative blurred orbs ──────────────────────────────────────
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(
            size: 260,
            color: isDark
                ? AppTheme.primarySeed.withOpacity(0.18)
                : AppTheme.primarySeed.withOpacity(0.12),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: _GlowOrb(
            size: 220,
            color: isDark
                ? const Color(0xFF06B6D4).withOpacity(0.10)
                : const Color(0xFF818CF8).withOpacity(0.10),
          ),
        ),

        // ── Actual Scaffold ──────────────────────────────────────────────
        Scaffold(
          backgroundColor: backgroundColor ?? Colors.transparent,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}

/// Soft blurred circle used as a background decoration.
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
