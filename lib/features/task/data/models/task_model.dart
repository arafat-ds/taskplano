import 'package:taskflow/features/task/domain/entities/task_entity.dart';

/// TaskModel is the DATA layer representation of a task.
///
/// In the in-memory phase it is a plain Dart class with no framework deps.
/// When Hive is introduced, add:
///   import 'package:hive/hive.dart';
///   part 'task_model.g.dart';
///   @HiveType(typeId: 0) on the class
///   @HiveField(n) on each field
/// and run: dart run build_runner build --delete-conflicting-outputs
class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
  });

  /// Creates a TaskModel from a domain entity.
  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isCompleted: entity.isCompleted,
        createdAt: entity.createdAt,
        dueDate: entity.dueDate,
      );

  /// Converts this model into a pure domain entity.
  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
        createdAt: createdAt,
        dueDate: dueDate,
      );
}
