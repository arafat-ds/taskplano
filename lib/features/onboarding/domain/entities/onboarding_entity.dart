import 'package:equatable/equatable.dart';

/// OnboardingEntity represents a single onboarding slide.
class OnboardingEntity extends Equatable {
  final String title;
  final String description;
  final String iconAsset; // e.g. an icon name or asset path

  const OnboardingEntity({
    required this.title,
    required this.description,
    required this.iconAsset,
  });

  @override
  List<Object?> get props => [title, description, iconAsset];
}
