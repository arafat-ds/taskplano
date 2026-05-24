/// Validators provides static helper methods for common input validation.
/// Used in both the UI (form fields) and the domain layer (use cases).
class Validators {
  Validators._();

  /// Returns an error string if [value] is null or empty, otherwise null.
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates a task title: required and max 200 characters.
  static String? taskTitle(String? value) {
    final requiredError = required(value, fieldName: 'Title');
    if (requiredError != null) return requiredError;
    if (value!.trim().length > 200) {
      return 'Title must be 200 characters or fewer.';
    }
    return null;
  }

  /// Basic email format check.
  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Password must be at least 6 characters.
  static String? password(String? value) {
    final requiredError = required(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }
}
