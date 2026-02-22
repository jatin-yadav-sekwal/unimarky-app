import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

/// Entry point — mirrors the web app's `main.tsx`.
///
/// Initialization order:
///   1. Load .env (environment variables)
///   2. Initialize Supabase
///   3. Run the app inside ProviderScope (Riverpod)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase — equivalent of createClient() in lib/supabase.ts
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
