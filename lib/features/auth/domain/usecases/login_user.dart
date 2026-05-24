import 'package:taskflow/features/auth/domain/entities/user_entity.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// LoginUser use case encapsulates the login business logic.
class LoginUser {
  final AuthRepository repository;

  const LoginUser(this.repository);

  Future<Result<UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
