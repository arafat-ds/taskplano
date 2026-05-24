import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/theme/theme_cubit.dart';
import 'package:taskflow/core/theme/theme_state.dart';
import 'package:taskflow/core/widgets/gradient_scaffold.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    // Load profile from the already-authenticated user in AuthCubit.
    // This avoids a redundant Supabase call and eliminates the
    // "No user logged in" false-negative.
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().loadFromUser(authState.user);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
    // GoRouter's refreshListenable will redirect to /login automatically.
    // We also navigate explicitly for immediate feedback.
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You have been signed out.'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return GradientScaffold(
      extendBodyBehindAppBar: true,
      appBar: _ProfileAppBar(isDark: isDark, topPadding: topPadding),
      body: BlocListener<AuthCubit, AuthState>(
        // If auth state becomes unauthenticated from an external event
        // (e.g. token expiry), redirect to login immediately.
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            // ── Loading ────────────────────────────────────────────────────
            if (state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Error ──────────────────────────────────────────────────────
            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 12),
                      Text(state.message,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge),
                    ],
                  ),
                ),
              );
            }

            // ── Loaded ─────────────────────────────────────────────────────
            if (state is ProfileLoaded) {
              final profile = state.profile;
              final initial = profile.name.isNotEmpty
                  ? profile.name[0].toUpperCase()
                  : '?';

              return SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(20, topPadding + 72, 20, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Avatar ─────────────────────────────────────────────
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4F46E5).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      profile.name,
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Settings card ──────────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.10)
                                  : Colors.white.withOpacity(0.9),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Theme toggle
                              BlocBuilder<ThemeCubit, ThemeState>(
                                builder: (context, themeState) {
                                  return _SettingsRow(
                                    icon: themeState.isDark
                                        ? Icons.light_mode_rounded
                                        : Icons.dark_mode_rounded,
                                    label: themeState.isDark
                                        ? 'Light Mode'
                                        : 'Dark Mode',
                                    trailing: Switch(
                                      value: themeState.isDark,
                                      onChanged: (_) => context
                                          .read<ThemeCubit>()
                                          .toggleTheme(),
                                      activeColor:
                                          const Color(0xFF4F46E5),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: colorScheme.outline.withOpacity(0.1),
                              ),
                              _SettingsRow(
                                icon: Icons.info_outline_rounded,
                                label: 'Version',
                                trailing: Text(
                                  '1.0.0',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Logout button ──────────────────────────────────────
                    GestureDetector(
                      onTap: _isLoggingOut ? null : _handleLogout,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                const Color(0xFFEF4444).withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: _isLoggingOut
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFEF4444),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_rounded,
                                        color: Color(0xFFEF4444), size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final double topPadding;
  const _ProfileAppBar({required this.isDark, required this.topPadding});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings row ──────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
