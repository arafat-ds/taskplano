import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/gradient_scaffold.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  /// Shows a bottom sheet informing the user to confirm their email.
  void _showEmailConfirmationSheet(String email) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'Check your inbox',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a confirmation link to\n$email\n\nClick the link to activate your account, then sign in.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/login');
                  },
                  child: const Text(
                    'Go to Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return GradientScaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Supabase confirmed the session immediately (no email confirmation).
            context.go('/tasks');
          } else if (state is AuthSignUpSuccess) {
            _showEmailConfirmationSheet(state.email);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      // ── Brand mark ───────────────────────────────────────
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primarySeed.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'TaskPlano',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Plan smarter. Do more.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Glass form card ──────────────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Create account',
                                    style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Start organising your tasks today',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(
                                          Icons.email_outlined,
                                          size: 20),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 12),

                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.password,
                                  ),
                                  const SizedBox(height: 12),

                                  // Confirm password
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm password',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureConfirm =
                                                !_obscureConfirm),
                                      ),
                                    ),
                                    obscureText: _obscureConfirm,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password.';
                                      }
                                      if (value !=
                                          _passwordController.text) {
                                        return 'Passwords do not match.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit button
                                  BlocBuilder<AuthCubit, AuthState>(
                                    builder: (context, state) {
                                      return GestureDetector(
                                        onTap: state is AuthLoading
                                            ? null
                                            : _submit,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          height: 54,
                                          decoration: BoxDecoration(
                                            gradient: state is AuthLoading
                                                ? null
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(0xFF4F46E5),
                                                      Color(0xFF7C3AED),
                                                    ],
                                                    begin:
                                                        Alignment.topLeft,
                                                    end: Alignment
                                                        .bottomRight,
                                                  ),
                                            color: state is AuthLoading
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow:
                                                state is AuthLoading
                                                    ? []
                                                    : [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF4F46E5)
                                                              .withOpacity(
                                                                  0.4),
                                                          blurRadius: 16,
                                                          offset:
                                                              const Offset(
                                                                  0, 6),
                                                        ),
                                                      ],
                                          ),
                                          child: Center(
                                            child: state is AuthLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : const Text(
                                                    'Create Account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Sign in link ─────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Sign In',
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF4F46E5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
