import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

void main() async {
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  final client = Supabase.instance.client;
  
  try {
    final jobs = await client.from('jobs').select('posted_by_id').limit(5);
    final posterIds = jobs.map((e) => e['posted_by_id']?.toString()).whereType<String>().toList();
    print('Poster IDs: $posterIds');
    
    if (posterIds.isNotEmpty) {
      final profiles = await client.from('profiles').select('id, full_name, avatar_url').inFilter('id', posterIds);
      print('Profiles: $profiles');
    }
  } catch (e) {
    print('Error: $e');
  }
}
