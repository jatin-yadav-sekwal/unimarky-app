import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized app configuration loaded from .env file.
class AppConfig {
  AppConfig._();

  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
