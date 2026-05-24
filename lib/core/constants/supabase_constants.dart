/// SupabaseConstants holds the Supabase project credentials.
///
/// These values are safe to commit for a Flutter mobile app — the anon key
/// is a publishable key that is protected by Row Level Security (RLS) on the
/// Supabase side, not by keeping it secret.
///
/// For production, consider loading these from a .env file via
/// flutter_dotenv if you want to support multiple environments
/// (dev / staging / prod) without code changes.
class SupabaseConstants {
  SupabaseConstants._();

  /// The base URL of your Supabase project.
  static const String supabaseUrl =
      'https://tbsubgtrmjeguczpsvwf.supabase.co';

  /// The publishable anon key for your Supabase project.
  /// Protected by RLS — safe to include in client-side code.
  static const String supabaseAnonKey =
      'sb_publishable_BFVaKhZaCep5tofr7Top5w_-DU9hzjz';

  // ── Table names ───────────────────────────────────────────────────────────
  // Centralise table name strings here so a rename only touches one file.
  static const String tasksTable = 'tasks';
  static const String profilesTable = 'profiles';
}
