// lib/data/repositories/job_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import '../../core/config/supabase_config.dart';

class JobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all open jobs with optional filters
  Future<List<JobModel>> getJobs({
    String? category,
    String? city,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from(SupabaseConfig.jobsTable)
        .select();

    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }
    if (city != null) {
      query = query.eq('city', city);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _enrichWithProfiles(data as List);
  }

  Future<List<JobModel>> _enrichWithProfiles(List<dynamic> data) async {
    if (data.isEmpty) return [];
    try {
      final List<String> posterIds = data
          .map((e) => e['user_id']?.toString() ?? e['posted_by_id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
          
      if (posterIds.isEmpty) return data.map((e) => JobModel.fromJson(e)).toList();

      final profilesData = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select('id, full_name, avatar_url')
          .filter('id', 'in', posterIds);
          
      final profilesMap = {
        for (var p in profilesData) 
          p['id'] as String: p
      };

      final jobModels = <JobModel>[];
      for (var e in data) {
        final jobMap = Map<String, dynamic>.from(e);
        final String? posterId = jobMap['user_id']?.toString() ?? jobMap['posted_by_id']?.toString();
        if (posterId != null && profilesMap.containsKey(posterId)) {
          jobMap['profiles'] = profilesMap[posterId];
        }
        jobModels.add(JobModel.fromJson(jobMap));
      }
      return jobModels;
    } catch (e) {
      print('Error enriching profiles: $e');
      return data.map((e) => JobModel.fromJson(e)).toList();
    }
  }

  /// Fetch featured jobs for home screen
  Future<List<JobModel>> getFeaturedJobs() async {
    try {
      final data = await _supabase
          .from(SupabaseConfig.jobsTable)
          .select()
          .limit(5);

      return _enrichWithProfiles(data as List);
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single job by ID
  Future<JobModel> getJobById(String jobId) async {
    final data = await _supabase
        .from(SupabaseConfig.jobsTable)
        .select()
        .eq('id', jobId)
        .single();

    final enriched = await _enrichWithProfiles([data]);
    return enriched.first;
  }

  /// Post a new job
  Future<JobModel> postJob({
    required String title,
    required String description,
    required String category,
    required String city,
    String? address,
    required double budget,
    String budgetType = 'fixed',
    String jobType = 'part_time',
    List<String> skills = const [],
    DateTime? deadline,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to post a job');

    // Get user profile for name
    final profile = await _supabase
        .from(SupabaseConfig.profilesTable)
        .select('full_name, avatar_url')
        .eq('id', user.id)
        .single();

    final jobData = {
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'address': address,
      'budget': budget,
      'budget_type': budgetType,
      'job_type': jobType,
      'status': 'open',
      'user_id': user.id,
      'posted_by_name': profile['full_name'] ?? 'Anonymous',
      'posted_by_avatar': profile['avatar_url'],
      'skills': skills,
      'deadline': deadline?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    final data = await _supabase
        .from(SupabaseConfig.jobsTable)
        .insert(jobData)
        .select()
        .single();

    return JobModel.fromJson(data);
  }

  /// Apply for a job
  Future<void> applyForJob({
    required String jobId,
    required String coverLetter,
    double? proposedBudget,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to apply');

    await _supabase.from(SupabaseConfig.applicationsTable).insert({
      'job_id': jobId,
      'applicant_id': user.id,
      'cover_letter': coverLetter,
      'proposed_budget': proposedBudget,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Increment application count
    await _supabase.rpc('increment_application_count', params: {'job_id': jobId});
  }

  /// Get jobs posted by a user
  Future<List<JobModel>> getMyPostedJobs(String userId) async {
    final data = await _supabase
        .from(SupabaseConfig.jobsTable)
        .select()
        .eq('posted_by_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => JobModel.fromJson(e)).toList();
  }

  /// Get real-time job updates stream
  Stream<List<JobModel>> watchJobs() {
    return _supabase
        .from(SupabaseConfig.jobsTable)
        .stream(primaryKey: ['id'])
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .limit(20)
        .map((data) => data.map((e) => JobModel.fromJson(e)).toList());
  }
}
