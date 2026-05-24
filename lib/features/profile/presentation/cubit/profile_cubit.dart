import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/profile/domain/entities/profile_entity.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_state.dart';

/// ProfileCubit loads the current user's profile.
///
/// It receives the [UserEntity] directly from the caller (AuthCubit state)
/// rather than making a redundant repository call. This guarantees the
/// profile page always shows the same user that is already authenticated,
/// with no extra network round-trip and no "No user logged in" false-negative.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  /// Loads the profile from the already-authenticated [UserEntity].
  ///
  /// Call this from the profile page's [initState], passing the user from
  /// `context.read<AuthCubit>().currentUser`.
  void loadFromUser(UserEntity user) {
    emit(ProfileLoaded(
      ProfileEntity(id: user.id, name: user.name, email: user.email),
    ));
  }

  /// Clears the profile state — called on logout.
  void clear() => emit(const ProfileInitial());
}
