// lib/core/config/router_config.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/job_detail/job_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/post_job/post_job_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Allow splash and onboarding always
      if (isSplash || isOnboarding) return null;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.onboarding;
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.jobDetail}/:id',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.postJob,
        builder: (context, state) => const PostJobScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF00E5CC), size: 48),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home',
                  style: TextStyle(color: Color(0xFF00E5CC))),
            ),
          ],
        ),
      ),
    ),
  );
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String jobDetail = '/job';
  static const String profile = '/profile';
  static const String postJob = '/post-job';
}
