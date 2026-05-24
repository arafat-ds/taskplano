import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/profile/domain/entities/profile_entity.dart';
import 'package:taskflow/features/profile/presentation/cubit/profile_state.dart';

/// ProfileCubit loads the current user's profile from the auth repository.
///
/// It reuses AuthRepository because profile data is the same as auth data
/// in this starter. Add a dedicated ProfileRepository when profile editing
/// (avatar, bio, etc.) is introduced.
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository authRepository;

  ProfileCubit({required this.authRepository}) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) {
        if (user == null) {
          emit(const ProfileError('No user logged in.'));
        } else {
          emit(ProfileLoaded(
            ProfileEntity(id: user.id, name: user.name, email: user.email),
          ));
        }
      },
    );
  }
}
