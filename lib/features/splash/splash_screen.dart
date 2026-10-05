// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/router_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Wait then navigate
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) _navigate();
  }

  void _navigate() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Stack(
          children: [
            // Animated background orbs
            _buildBackgroundOrbs(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoController, _glowController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              AnimatedOpacity(
                                opacity: _glowOpacity.value,
                                duration: Duration.zero,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withOpacity(0.4),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Logo container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  color: AppColors.bgCard,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/elinker_logo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.link,
                                      color: AppColors.primary,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // App name and tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              // App name
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'E',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'linker',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tagline
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  AppStrings.appTagline,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Version badge
                              Text(
                                AppStrings.appVersion,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom loading indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.copyright,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        // Top-left orb
        Positioned(
          top: -80,
          left: -80,
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Opacity(
                opacity: _glowOpacity.value * 0.3,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom-right orb
        Positioned(
          bottom: -100,
          right: -80,
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Opacity(
                opacity: (1 - _glowOpacity.value) * 0.3 + 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
