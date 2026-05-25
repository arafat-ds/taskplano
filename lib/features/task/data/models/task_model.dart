import 'package:taskflow/features/task/domain/entities/task_entity.dart';

/// TaskModel is the DATA layer representation of a task.
///
/// Handles JSON serialization for Supabase (PostgREST) responses.
/// The [fromJson] / [toJson] methods map between Dart types and the
/// Supabase column names defined in the tasks table.
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

  // ── JSON ──────────────────────────────────────────────────────────────────

  /// Deserialises a Supabase row (snake_case keys) into a [TaskModel].
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        isCompleted: (json['is_completed'] as bool?) ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
      );

  /// Serialises this model to a map for Supabase insert/update.
  /// Keys match the Supabase column names exactly.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
      };

  // ── Domain conversion ─────────────────────────────────────────────────────

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
