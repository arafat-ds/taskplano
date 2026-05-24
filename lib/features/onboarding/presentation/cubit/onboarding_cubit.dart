import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/features/onboarding/presentation/cubit/onboarding_state.dart';

/// OnboardingCubit manages slide navigation and persists completion status.
class OnboardingCubit extends Cubit<OnboardingState> {
  final Box<dynamic> _box;
  static const int _totalPages = 3;

  OnboardingCubit(this._box) : super(const OnboardingInitial());

  /// Returns true if the user has already completed onboarding.
  bool get isCompleted =>
      _box.get(AppConstants.onboardingCompletedKey, defaultValue: false)
          as bool;

  /// Starts the onboarding flow.
  void start() {
    emit(const OnboardingInProgress(currentPage: 0, totalPages: _totalPages));
  }

  /// Advances to the next slide, or completes onboarding on the last slide.
  Future<void> nextPage() async {
    final current = state;
    if (current is OnboardingInProgress) {
      if (current.isLastPage) {
        await _complete();
      } else {
        emit(OnboardingInProgress(
          currentPage: current.currentPage + 1,
          totalPages: _totalPages,
        ));
      }
    }
  }

  /// Skips onboarding entirely.
  Future<void> skip() async => _complete();

  Future<void> _complete() async {
    await _box.put(AppConstants.onboardingCompletedKey, true);
    emit(const OnboardingCompleted());
  }
}
