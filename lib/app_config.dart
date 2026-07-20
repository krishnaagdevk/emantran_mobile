import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application Configuration
/// Handles runtime and compile-time environment configurations for the Flutter Mobile Client.
class AppConfig {
  /// The base URL of the Emantran backend API server.
  /// Reads from the loaded `.env` file, falling back to compile-time variables.
  static String get apiUrl => dotenv.env['API_URL'] ?? const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// The base URL for public assets hosted on Cloudflare R2.
  static String get r2PublicUrl => dotenv.env['R2_PUBLIC_URL'] ?? const String.fromEnvironment(
    'R2_PUBLIC_URL',
    defaultValue: 'https://pub-your-bucket-id.r2.dev',
  );
}
