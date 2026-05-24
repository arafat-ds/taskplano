import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskflow/core/constants/supabase_constants.dart';

/// SupabaseService is the single entry point for all Supabase operations.
///
/// Responsibilities:
///   - Initialise the Supabase client once at app startup.
///   - Expose a typed [client] getter used by datasources and repositories.
///
/// Usage:
///   await SupabaseService.initialize();          // call once in main()
///   final client = SupabaseService.client;       // use anywhere
///
/// Architecture note:
///   Datasources receive [SupabaseClient] via constructor injection from
///   injection_container.dart — they never call SupabaseService directly.
///   This keeps datasources testable and decoupled from the singleton.
class SupabaseService {
  SupabaseService._();

  /// Initialises the Supabase Flutter SDK.
  ///
  /// Must be called after [WidgetsFlutterBinding.ensureInitialized] and
  /// before any Supabase operation. Safe to call multiple times — the SDK
  /// is a no-op on subsequent calls if already initialised.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
      // debug: false in production — set to true during development to
      // see realtime and auth events in the console.
      debug: false,
    );
  }

  /// Returns the initialised [SupabaseClient] singleton.
  ///
  /// Throws a [StateError] if called before [initialize].
  static SupabaseClient get client => Supabase.instance.client;

  /// Convenience getter for the current authenticated user.
  /// Returns null if no session is active.
  static User? get currentUser => client.auth.currentUser;

  /// Returns true if a user session is currently active.
  static bool get isAuthenticated => currentUser != null;
}
