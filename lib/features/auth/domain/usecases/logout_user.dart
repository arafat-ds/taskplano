import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/shared/models/result.dart';

/// LogoutUser use case signs out the current user via the auth repository.
class LogoutUser {
  final AuthRepository repository;

  const LogoutUser(this.repository);

  Future<Result<void>> call() {
    return repository.logout();
  }
}
