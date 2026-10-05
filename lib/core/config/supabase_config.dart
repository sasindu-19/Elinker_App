// lib/core/config/supabase_config.dart

class SupabaseConfig {
  SupabaseConfig._();

  // TODO: Replace with your actual Supabase project credentials
  // Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
  static const String supabaseUrl = 'https://ijmbjtypajvecijbwvfx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqbWJqdHlwYWp2ZWNpamJ3dmZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1NDIwNjEsImV4cCI6MjA5MTExODA2MX0.1H2BtyB0RFcqzcUdXDMhqThO2WiyIO18kAuk6OQqBY4';

  // Table Names
  static const String profilesTable = 'profiles';
  static const String jobsTable = 'jobs';
  static const String applicationsTable = 'applications';
  static const String reviewsTable = 'reviews';
  static const String categoriesTable = 'categories';
  static const String notificationsTable = 'notifications';

  // Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String jobImagesBucket = 'job-images';

  // Edge Function Names
  static const String sendNotificationFn = 'send-notification';
}
