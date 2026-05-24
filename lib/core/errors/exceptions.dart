/// Exceptions are thrown in the DATA layer (datasources, repositories).
/// They are caught by repository implementations and converted into Failures
/// before being returned to the domain layer via Either<Failure, T>.

/// Thrown when a Hive / local-storage operation fails.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when a required item cannot be found in the local store.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Item not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Thrown when input data fails validation inside a datasource.
class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation failed.']);

  @override
  String toString() => 'ValidationException: $message';
}

/// Thrown when a Supabase Auth operation fails (wrong password, email taken, etc.).
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);

  @override
  String toString() => 'AuthException: $message';
}

/// Thrown when a Supabase network / server call fails unexpectedly.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error.']);

  @override
  String toString() => 'ServerException: $message';
}
