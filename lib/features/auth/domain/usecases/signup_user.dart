import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// SignUpUser use case registers a new user via the auth repository.
class SignUpUser {
  final AuthRepository repository;

  const SignUpUser(this.repository);

  Future<Result<UserEntity>> call(String email, String password) {
    return repository.signUp(email, password);
  }
}
