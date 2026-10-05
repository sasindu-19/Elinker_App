// lib/data/models/job_model.dart

class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? categoryIcon;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double budget;
  final String budgetType; // 'fixed' | 'hourly' | 'daily'
  final String jobType; // 'full_time' | 'part_time' | 'freelance'
  final String status; // 'open' | 'in_progress' | 'completed' | 'cancelled'
  final String postedById;
  final String postedByName;
  final String? postedByAvatar;
  final bool isVerified;
  final bool isFeatured;
  final int applicationCount;
  final List<String> skills;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? deadline;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categoryIcon,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    required this.budget,
    this.budgetType = 'fixed',
    this.jobType = 'part_time',
    this.status = 'open',
    required this.postedById,
    required this.postedByName,
    this.postedByAvatar,
    this.isVerified = false,
    this.isFeatured = false,
    this.applicationCount = 0,
    this.skills = const [],
    this.imageUrls = const [],
    required this.createdAt,
    this.deadline,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;

    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      categoryIcon: json['category_icon'] as String?,
      city: json['city'] as String? ?? 'Colombo',
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      budget: json['budget'] != null ? double.tryParse(json['budget'].toString()) ?? 0.0 : 0.0,
      budgetType: json['budget_type'] as String? ?? 'fixed',
      jobType: json['job_type'] as String? ?? 'part_time',
      status: json['status'] as String? ?? 'open',
      postedById: json['user_id'] as String? ?? json['posted_by_id'] as String? ?? '',
      postedByName: profiles?['full_name'] as String? ?? json['posted_by_name'] as String? ?? 'Elinker Client',
      postedByAvatar: profiles?['avatar_url'] as String? ?? json['posted_by_avatar'] as String?,
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
      isFeatured: json['is_featured'] == true || json['is_featured'] == 'true',
      applicationCount: json['application_count'] != null ? int.tryParse(json['application_count'].toString()) ?? 0 : 0,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'category_icon': categoryIcon,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'budget': budget,
      'budget_type': budgetType,
      'job_type': jobType,
      'status': status,
      'posted_by_id': postedById,
      'posted_by_name': postedByName,
      'posted_by_avatar': postedByAvatar,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'application_count': applicationCount,
      'skills': skills,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
    };
  }

  String get formattedBudget {
    final formatted = budget.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    switch (budgetType) {
      case 'hourly':
        return 'LKR $formatted/hr';
      case 'daily':
        return 'LKR $formatted/day';
      default:
        return 'LKR $formatted';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// Job Categories
class JobCategory {
  final String id;
  final String name;
  final String icon;
  final int jobCount;

  const JobCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.jobCount = 0,
  });

  static List<JobCategory> get defaults => [
        const JobCategory(id: 'all', name: 'All Jobs', icon: '🔍'),
        const JobCategory(id: 'tech', name: 'Tech & IT', icon: '💻'),
        const JobCategory(
            id: 'construction', name: 'Construction', icon: '🔨'),
        const JobCategory(id: 'creative', name: 'Creative', icon: '🎨'),
        const JobCategory(id: 'delivery', name: 'Delivery', icon: '🚚'),
        const JobCategory(id: 'domestic', name: 'Domestic', icon: '🏠'),
        const JobCategory(id: 'education', name: 'Education', icon: '📚'),
        const JobCategory(id: 'food', name: 'Food & Catering', icon: '🍽️'),
        const JobCategory(id: 'beauty', name: 'Beauty & Salon', icon: '💄'),
        const JobCategory(id: 'other', name: 'Other', icon: '📋'),
      ];
}
