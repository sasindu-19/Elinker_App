// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final String userType; // 'worker' | 'client' | 'both'
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final List<String> skills;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.city,
    this.userType = 'both',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.skills = const [],
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      userType: json['user_type'] as String? ?? 'both',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'city': city,
      'user_type': userType,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'skills': skills,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? city,
    String? userType,
    List<String>? skills,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      userType: userType ?? this.userType,
      rating: rating,
      reviewCount: reviewCount,
      isVerified: isVerified,
      skills: skills ?? this.skills,
      createdAt: createdAt,
    );
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
