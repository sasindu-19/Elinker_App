// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/router_config.dart';
import '../../data/models/job_model.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../profile/profile_screen.dart';
import '../post_job/post_job_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jobRepo = JobRepository();
  final _authRepo = AuthRepository();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  int _selectedIndex = 0;
  String _selectedCategory = 'all';
  String? _selectedCity;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _hasMoreJobs = true;

  List<JobModel> _jobs = [];
  List<JobModel> _featuredJobs = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoadingMore || !_hasMoreJobs || _isLoading || _isSearching) return;
    setState(() => _isLoadingMore = true);
    try {
      final moreJobs = await _jobRepo.getJobs(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        city: _selectedCity,
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        offset: _jobs.length,
      );
      if (mounted) {
        setState(() {
          if (moreJobs.isEmpty) {
            _hasMoreJobs = false;
          } else {
            _jobs.addAll(moreJobs);
          }
        });
      }
    } catch (e) {
      // Handle silently
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authRepo.currentUserId;
      
      final futures = <Future>[];
      
      // Load independently so one failure doesn't block the others
      if (userId != null) {
        futures.add(_authRepo.getProfile(userId).then((profile) {
          if (mounted) setState(() => _currentUser = profile);
        }).catchError((_) {}));
      }

      futures.add(_jobRepo.getJobs().then((jobs) {
        if (mounted) setState(() => _jobs = jobs);
      }).catchError((_) {}));

      futures.add(_jobRepo.getFeaturedJobs().then((jobs) {
        if (mounted) setState(() => _featuredJobs = jobs);
      }).catchError((_) {}));

      await Future.wait(futures);
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchJobs(String query) async {
    setState(() => _isSearching = true);
    try {
      final jobs = await _jobRepo.getJobs(
        searchQuery: query,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        city: _selectedCity,
      );
      if (mounted) setState(() => _jobs = jobs);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    try {
      final jobs = await _jobRepo.getJobs(
        category: category == 'all' ? null : category,
        city: _selectedCity,
        searchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      );
      if (mounted) setState(() => _jobs = jobs);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> get _screens {
    final role = _currentUser?.userType ?? 'worker';
    final screens = <Widget>[_buildHomeTab()];
    
    if (role == 'client' || role == 'both') {
      screens.add(const PostJobScreen());
    }
    
    if (role == 'worker' || role == 'both') {
      screens.add(const Center(
        child: Text('My Applications\n(Coming Soon)', 
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontFamily: 'Poppins')),
      ));
    }
    
    screens.add(const ProfileScreen());
    return screens;
  }

  List<Widget> _buildNavItems() {
    final role = _currentUser?.userType ?? 'worker';
    final items = <Widget>[
      _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
    ];
    
    int index = 1;
    if (role == 'client' || role == 'both') {
      items.add(_buildNavItem(index++, Icons.add_circle_rounded, Icons.add_circle_outline_rounded, 'Post Job'));
    }
    
    if (role == 'worker' || role == 'both') {
      items.add(_buildNavItem(index++, Icons.work_history_rounded, Icons.work_history_outlined, 'Applications'));
    }
    
    items.add(_buildNavItem(index++, Icons.person_rounded, Icons.person_outline, 'Profile'));
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                RichText(
                  text: const TextSpan(
                    text: 'Find You ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Smart',
                        style: TextStyle(color: AppColors.error),
                      ),
                      TextSpan(text: ' Work'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Find work the smart way with opportunities that match your skills and lifestyle. Skip the stress of traditional job searching and connect quickly with roles that fit you best.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildWebLikeProfileCard(),
                const SizedBox(height: 24),
                _buildWebLikeFilterBar(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        
        _isLoading
            ? SliverToBoxAdapter(child: _buildShimmerList())
            : _jobs.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _buildJobCard(_jobs[index]),
                        );
                      },
                      childCount: _jobs.length,
                    ),
                  ),
        if (_isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildWebLikeProfileCard() {
    if (_currentUser == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B80F9).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgElevated,
              image: _currentUser!.avatarUrl != null
                  ? DecorationImage(image: NetworkImage(_currentUser!.avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: _currentUser!.avatarUrl == null
                ? Center(child: Text(_currentUser!.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser!.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_currentUser!.city ?? 'Sri Lanka'} · Age 22 · Male',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFF8B80F9).withOpacity(0.5)),
            ),
            child: const Text('Male', style: TextStyle(color: Color(0xFF8B80F9), fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB46E13).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFFB46E13)),
            ),
            child: const Text('22 yrs', style: TextStyle(color: Color(0xFFB46E13), fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLikeFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('FILTER:', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown('All Modes'),
                  const SizedBox(width: 6),
                  _buildFilterDropdown('All Districts'),
                  const SizedBox(width: 6),
                  _buildFilterDropdown('All Difficulty'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Poppins')),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 14),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Network bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      AppStrings.networkOnline,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.textMuted, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.mainCities.join(' • '),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Greeting + notification
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentUser?.fullName.split(' ')[0] ?? 'Explorer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification bell
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary, size: 20),
                ),

                const SizedBox(width: 10),

                // Avatar
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 2),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgCard,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4)),
                      image: _currentUser?.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_currentUser!.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _currentUser?.avatarUrl == null
                        ? Center(
                            child: Text(
                              _currentUser?.initials ?? '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats strip
            _buildStatsStrip(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    return Row(
      children: [
        _buildStatPill(Icons.flash_on_rounded, AppStrings.instantHire,
            AppStrings.instantHireDesc),
        const SizedBox(width: 8),
        _buildStatPill(Icons.shield_rounded, AppStrings.lkrEscrow,
            AppStrings.lkrEscrowDesc),
        const SizedBox(width: 8),
        _buildStatPill(Icons.location_on_rounded, AppStrings.geoFenced,
            AppStrings.geoFencedDesc),
      ],
    );
  }

  Widget _buildStatPill(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: AppStrings.search,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontFamily: 'Poppins'),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                ),
                onChanged: (v) {
                  if (v.length >= 2 || v.isEmpty) _searchJobs(v);
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = JobCategory.defaults;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat.id;
          return GestureDetector(
            onTap: () => _filterByCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderDefault,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedJobsCarousel() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredJobs.length,
        itemBuilder: (context, index) {
          final job = _featuredJobs[index];
          return GestureDetector(
            onTap: () => context.push('${AppRoutes.jobDetail}/${job.id}'),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E2040), Color(0xFF0A1628)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.warning, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        job.timeAgo,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.textMuted, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            job.city,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        job.formattedBudget,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.jobDetail}/${job.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster info
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgElevated,
                    image: job.postedByAvatar != null 
                        ? DecorationImage(image: NetworkImage(job.postedByAvatar!), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: job.postedByAvatar == null 
                      ? const Icon(Icons.person, size: 16, color: AppColors.textMuted) 
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  job.postedByName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Individual', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              job.title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Text('${job.city}, Sri Lanka', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text('Deadline: 2026-10-30', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 11),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.success, size: 11),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgElevated,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const Icon(Icons.work_off_outlined,
              color: AppColors.textMuted, size: 56),
          const SizedBox(height: 16),
          const Text(
            'No jobs found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search or filters',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
