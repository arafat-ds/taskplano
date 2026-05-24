import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/widgets/gradient_scaffold.dart';
import 'package:taskflow/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  static const List<OnboardingEntity> _slides = [
    OnboardingEntity(
      title: 'Plan with clarity',
      description:
          'TaskPlano helps you capture every idea and turn it into action — beautifully organised.',
      iconAsset: 'task_alt',
    ),
    OnboardingEntity(
      title: 'Track your momentum',
      description:
          'Watch your progress in real time. Every completed task is a step forward.',
      iconAsset: 'trending_up',
    ),
    OnboardingEntity(
      title: 'Stay in flow',
      description:
          'A distraction-free workspace designed to keep you focused on what truly matters.',
      iconAsset: 'center_focus_strong',
    ),
  ];

  static const List<List<Color>> _slideGradients = [
    [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    [Color(0xFF10B981), Color(0xFF0EA5E9)],
  ];

  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().start();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingInProgress) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
        if (state is OnboardingCompleted) context.go('/login');
      },
      child: GradientScaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final currentPage =
                  state is OnboardingInProgress ? state.currentPage : 0;
              final isLast =
                  state is OnboardingInProgress && state.isLastPage;

              return Column(
                children: [
                  // ── Skip ──────────────────────────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: TextButton(
                        onPressed: () =>
                            context.read<OnboardingCubit>().skip(),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Slides ────────────────────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _slides.length,
                      itemBuilder: (_, index) => _SlideView(
                        slide: _slides[index],
                        gradient: _slideGradients[index],
                      ),
                    ),
                  ),

                  // ── Dots ──────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: i == currentPage
                              ? LinearGradient(
                                  colors: _slideGradients[currentPage])
                              : null,
                          color: i != currentPage
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.15)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── CTA button ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () =>
                          context.read<OnboardingCubit>().nextPage(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _slideGradients[currentPage],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _slideGradients[currentPage][0]
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isLast ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final OnboardingEntity slide;
  final List<Color> gradient;

  const _SlideView({required this.slide, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon orb
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  gradient[0].withOpacity(0.2),
                  gradient[1].withOpacity(0.0),
                ],
              ),
              border: Border.all(
                  color: gradient[0].withOpacity(0.25), width: 1.5),
            ),
            child: Icon(
              _iconFromName(slide.iconAsset),
              size: 56,
              color: gradient[0],
            ),
          ),
          const SizedBox(height: 36),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFromName(String name) => switch (name) {
        'task_alt' => Icons.task_alt_rounded,
        'trending_up' => Icons.trending_up_rounded,
        'center_focus_strong' => Icons.center_focus_strong_rounded,
        _ => Icons.star_outline_rounded,
      };
}
