import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failures.dart';

/// A convenience type alias used throughout the domain layer.
///
/// Instead of writing `Future<Either<Failure, T>>` everywhere, use:
///   `Future<Result<T>>`
///
/// Example:
///   Future<Result<List<TaskEntity>>> getAllTasks();
typedef Result<T> = Either<Failure, T>;
