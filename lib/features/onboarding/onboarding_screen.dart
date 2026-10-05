// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/router_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.flash_on_rounded,
      title: 'Find Local Experts',
      subtitle: 'INSTANT HIRE',
      description:
          'Browse verified technicians, freelancers, and service providers across Sri Lanka. Get hired in under 3 minutes.',
      color: AppColors.primary,
      features: ['Instant Hire', 'Verified Profiles', 'Geo-Fenced Matches'],
    ),
    _OnboardingData(
      icon: Icons.work_rounded,
      title: 'Post Your Job',
      subtitle: 'MICRO-JOBS & SERVICES',
      description:
          'Post any job in minutes. From fixing a sink to coding a website — Elinker gets it done fast.',
      color: const Color(0xFF7C4DFF),
      features: ['1,200+ Live Jobs', 'All Categories', 'Easy Posting'],
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      title: 'Safe & Secure',
      subtitle: 'LKR ESCROW',
      description:
          'Your money is protected with LKR Escrow payments. Pay only when the job is done to your satisfaction.',
      color: AppColors.success,
      features: ['Escrow Protection', 'Verified Workers', 'Secure Payouts'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animController.reset();
    _animController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          ),

          // Network status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNetworkBar(),
          ),

          // Page content
          Column(
            children: [
              // Top spacing for network bar
              const SizedBox(height: 48),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Network status
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),

            // Cities
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.textMuted, size: 12),
                const SizedBox(width: 4),
                Text(
                  AppStrings.mainCities.join(' • '),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo at top for first page, icon for others
          if (_currentPage == 0) ...[
            // Elinker logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/elinker_logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.bgCard,
                    child: const Icon(Icons.link,
                        color: AppColors.primary, size: 50),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Animated icon
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animController.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.color.withOpacity(0.1),
                      border: Border.all(
                        color: data.color.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: data.color, size: 52),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 32),

          // Version/subtitle badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: data.color.withOpacity(0.3)),
            ),
            child: Text(
              _currentPage == 0
                  ? '${AppStrings.appVersion} • ${data.subtitle}'
                  : data.subtitle,
              style: TextStyle(
                color: data.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            _currentPage == 0
                ? 'Find Local Experts &\nMicro-Jobs in Sri Lanka'
                : data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 32),

          // Feature pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: data.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: data.color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
      child: Column(
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Get Started button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _pages.length - 1
                        ? AppStrings.register
                        : 'Get Started',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.black, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Login button
          GestureDetector(
            onTap: () => context.go(AppRoutes.login),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded,
                      color: AppColors.textSecondary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.login,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Footer links
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.termsOfService,
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
              Text(' • ',
                  style: TextStyle(
                      color: AppColors.textMuted, fontFamily: 'Poppins')),
              Text(AppStrings.privacyPolicy,
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
              Text(' • ',
                  style: TextStyle(
                      color: AppColors.textMuted, fontFamily: 'Poppins')),
              Text(AppStrings.trustSafety,
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            AppStrings.copyright,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<String> features;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.features,
  });
}
