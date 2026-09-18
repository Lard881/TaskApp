/// Supabase project credentials.
/// These are safe to commit — the anon key is public by design.
/// All security is enforced by Row Level Security policies on the database.
abstract final class SupabaseConfig {
  static const String url = 'https://rnycqnrbkkkkgkehtbfb.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJueWNxbnJia2tra2drZWh0YmZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc2NjE4MDIsImV4cCI6MjEwMzIzNzgwMn0'
      '.69Itsa1WAXHjkw4h0L6v0AYnyKTsuRb_wKPtvFOMkOk';

  /// Google OAuth Web Client ID.
  /// Set this in the Google Cloud Console → Credentials.
  /// Also add your Supabase callback URL as an authorised redirect URI.
  static const String googleWebClientId =
      'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
}
