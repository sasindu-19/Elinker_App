// lib/data/repositories/auth_repository.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/config/supabase_config.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current logged-in user session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Register with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    if (response.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    // Create profile in profiles table
    final profile = UserModel(
      id: response.user!.id,
      email: email,
      fullName: fullName,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _supabase
        .from(SupabaseConfig.profilesTable)
        .upsert(profile.toJson());

    return profile;
  }

  /// Sign in with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed. Check your credentials.');
    }

    return await getProfile(response.user!.id);
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }
  /// Sign out
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Get user profile by ID
  Future<UserModel> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      // If profile doesn't exist (e.g., new Google login without trigger), auto-create one
      final user = _supabase.auth.currentUser;
      if (user != null && user.id == userId) {
        final profile = UserModel(
          id: userId,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? 'Elinker User',
          avatarUrl: user.userMetadata?['avatar_url'],
          createdAt: DateTime.now(),
        );
        
        await _supabase
            .from(SupabaseConfig.profilesTable)
            .upsert(profile.toJson());
            
        return profile;
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? city,
    List<String>? skills,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (bio != null) updates['bio'] = bio;
    if (city != null) updates['city'] = city;
    if (skills != null) updates['skills'] = skills;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final data = await _supabase
        .from(SupabaseConfig.profilesTable)
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Upload profile image to Supabase Storage
  Future<String> uploadProfileImage({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final path = '$userId/$fileName';
    await _supabase.storage
        .from(SupabaseConfig.profileImagesBucket)
        .uploadBinary(path, Uint8List.fromList(imageBytes), fileOptions: const FileOptions(upsert: true));

    final url = _supabase.storage
        .from(SupabaseConfig.profileImagesBucket)
        .getPublicUrl(path);

    // Update profile with new avatar URL
    await _supabase
        .from(SupabaseConfig.profilesTable)
        .update({'avatar_url': url})
        .eq('id', userId);

    return url;
  }
}
