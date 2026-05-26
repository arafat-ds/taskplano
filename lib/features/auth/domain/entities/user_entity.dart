import 'package:equatable/equatable.dart';

/// UserEntity is the pure domain representation of an authenticated user.
///
/// [needsEmailConfirmation] is a transient flag set during sign-up when
/// Supabase requires the user to click a confirmation link before their
/// session becomes active. It is never persisted — it only lives in memory
/// long enough for the cubit to emit [AuthSignUpSuccess].
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  /// True when the account was just created and Supabase has sent a
  /// confirmation email. The user exists in Auth > Users but cannot log in
  /// until they click the link.
  final bool needsEmailConfirmation;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.needsEmailConfirmation = false,
  });

  @override
  List<Object?> get props => [id, name, email, needsEmailConfirmation];
}
