import 'package:equatable/equatable.dart';

/// Failure is the base class for all domain-layer errors.
///
/// In Clean Architecture, use cases return Either<Failure, T>.
/// The UI layer maps Failure subtypes to user-friendly messages.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Returned when a local database operation fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

/// Returned when input validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}

/// Returned when an entity is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found.']);
}

/// Returned for unexpected / unclassified errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

/// Returned when a Supabase Auth operation fails.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Returned when a remote server call fails.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}
