import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskflow/core/constants/supabase_constants.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/task/data/models/task_model.dart';

/// TaskRemoteDatasource handles all Supabase database calls for tasks.
///
/// This is the ONLY class that knows about the Supabase tasks table.
/// Every method either returns data or throws a typed [ServerException]
/// that the repository converts into a domain [Failure].
///
/// Table schema (run in Supabase SQL editor):
/// ```sql
/// create table public.tasks (
///   id          uuid primary key default gen_random_uuid(),
///   user_id     uuid not null references auth.users(id) on delete cascade,
///   title       text not null,
///   description text not null default '',
///   is_completed boolean not null default false,
///   created_at  timestamptz not null default now(),
///   due_date    timestamptz
/// );
///
/// -- Row Level Security: users can only access their own tasks.
/// alter table public.tasks enable row level security;
///
/// create policy "Users can manage their own tasks"
///   on public.tasks for all
///   using  (auth.uid() = user_id)
///   with check (auth.uid() = user_id);
/// ```
abstract class TaskRemoteDatasource {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  final SupabaseClient client;

  const TaskRemoteDatasourceImpl({required this.client});

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _table => SupabaseConstants.tasksTable;

  /// Returns the current user's id or throws if not authenticated.
  String get _userId {
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw ServerException('User is not authenticated.');
    return uid;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((row) => TaskModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to fetch tasks: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch tasks: $e');
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final payload = task.toJson()..['user_id'] = _userId;
      // Remove client-generated id — let Supabase generate a UUID.
      payload.remove('id');

      final rows = await client
          .from(_table)
          .insert(payload)
          .select()
          .single();

      return TaskModel.fromJson(rows as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create task: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create task: $e');
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final payload = task.toJson()
        ..remove('id')
        ..remove('user_id')
        ..remove('created_at');

      final rows = await client
          .from(_table)
          .update(payload)
          .eq('id', task.id)
          .eq('user_id', _userId)
          .select()
          .single();

      return TaskModel.fromJson(rows as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update task: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update task: $e');
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteTask(String id) async {
    try {
      await client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to delete task: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete task: $e');
    }
  }
}
