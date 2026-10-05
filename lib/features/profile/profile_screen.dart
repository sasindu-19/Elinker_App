// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/router_config.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/job_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  final _jobRepo = JobRepository();

  UserModel? _user;
  List<JobModel> _myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _authRepo.currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        _authRepo.getProfile(userId),
        _jobRepo.getMyPostedJobs(userId).catchError((_) => <JobModel>[]),
      ]);
      if (mounted) {
        setState(() {
          _user = results[0] as UserModel;
          _myJobs = results[1] as List<JobModel>;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style:
              TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.textSecondary, fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out',
                style:
                    TextStyle(color: AppColors.error, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepo.logout();
      if (mounted) context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile not found',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Logout',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildPersonalInfoCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildAccountStatsCard(),
            const SizedBox(height: 16),
            _buildAccountTypeCard(),
            const SizedBox(height: 24),
            if (_user!.userType != 'worker') _buildMyJobsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineBtn(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF8B80F9), size: 16),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.textMuted, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgElevated,
              image: _user!.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_user!.avatarUrl!), fit: BoxFit.cover)
                  : null,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 2),
            ),
            child: _user!.avatarUrl == null
                ? Center(
                    child: Text(_user!.initials,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user!.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(_user!.email,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B2C),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFF00756A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle,
                          color: Color(0xFF00C4B4), size: 6),
                      const SizedBox(width: 4),
                      Text(_user!.userType.toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFF00C4B4),
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Column(
            children: [
              _buildOutlineBtn(
                  Icons.edit_outlined, 'Edit Profile', const Color(0xFF8B80F9)),
              const SizedBox(height: 8),
              _buildOutlineBtn(Icons.logout_rounded, 'Logout', AppColors.error,
                  onTap: _logout),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.person_outline, 'Personal Information'),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.badge_outlined, 'Full Name', _user!.fullName),
          _buildInfoRow(Icons.email_outlined, 'Email Address', _user!.email),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number',
              _user!.phone ?? 'Not provided'),
          _buildInfoRow(Icons.male_outlined, 'Gender', 'Not provided'),
          _buildInfoRow(
              Icons.calendar_month_outlined, 'Date of Birth', 'Not provided'),
          _buildInfoRow(
              Icons.credit_card_outlined, 'NIC Number', 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.location_on_outlined, 'Location'),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.map_outlined, 'Province', 'Southern'),
          _buildInfoRow(Icons.location_city_outlined, 'District', 'Galle'),
          _buildInfoRow(
              Icons.pin_drop_outlined, 'City', _user!.city ?? 'Elpitiya'),
        ],
      ),
    );
  }

  Widget _buildAccountStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.bar_chart_outlined, 'Account Stats'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatBox('144', 'Days Active')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox('May 2026', 'Member Since')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildStatBox('✓', 'Email Verified', isIcon: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox('💼', 'Client', isIcon: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String subtitle, {bool isIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: isIcon ? const Color(0xFF8B80F9) : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.verified_outlined, 'Account Type'),
          const SizedBox(height: 24),
          _buildInfoRow(
              Icons.work_outline,
              'Role',
              _user!.userType == 'both'
                  ? 'Both'
                  : (_user!.userType == 'client' ? 'Client' : 'Worker')),
          _buildInfoRow(Icons.gavel_outlined, 'Terms Agreed', 'Agreed'),
        ],
      ),
    );
  }

  Widget _buildMyJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardTitle(Icons.work_outline, 'My Posted Jobs'),
        const SizedBox(height: 16),
        if (_myJobs.isEmpty)
          const Text('No jobs posted yet.',
              style: TextStyle(color: AppColors.textMuted)),
        ..._myJobs.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(JobModel job) {
    final bool isExpired = job.status.toLowerCase() == 'expired' ||
        job.status.toLowerCase() == 'cancelled';
    final badgeColor = isExpired ? const Color(0xFFB46E13) : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins')),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                ),
                child: Text(isExpired ? 'EXPIRED' : job.status.toUpperCase(),
                    style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.textMuted, size: 14),
            const SizedBox(width: 6),
            Text('${job.city}, Sri Lanka',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12))
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.money_outlined,
                color: AppColors.textMuted, size: 14),
            const SizedBox(width: 6),
            Text(job.formattedBudget,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12))
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time_outlined,
                color: AppColors.textMuted, size: 14),
            const SizedBox(width: 6),
            Text('10/1/2026',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12))
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDefault)),
                  child: Center(
                      child: Text(isExpired ? 'Expired' : 'Active',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13))),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.error.withOpacity(0.3))),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
