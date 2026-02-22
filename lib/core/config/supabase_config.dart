import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

/// Initialize and expose the Supabase client — mirrors lib/supabase.ts.
class SupabaseConfig {
  SupabaseConfig._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
}
