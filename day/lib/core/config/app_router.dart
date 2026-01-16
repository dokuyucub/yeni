import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'placeholder_screens.dart';

/// App route paths
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const gallery = '/gallery';
  static const artworkDetail = '/gallery/:id';
  static const journal = '/journal';
  static const journalNew = '/journal/new';
  static const profile = '/profile';
  static const settings = '/settings';
  static const premium = '/premium';
  static const social = '/social';
}

/// GoRouter configuration for Day app
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // Splash screen
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // Home tab
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),

        // Gallery tab
        GoRoute(
          path: AppRoutes.gallery,
          name: 'gallery',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GalleryScreen(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              name: 'artworkDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ArtworkDetailScreen(artworkId: id);
              },
            ),
          ],
        ),

        // Journal tab
        GoRoute(
          path: AppRoutes.journal,
          name: 'journal',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: JournalScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              name: 'journalNew',
              builder: (context, state) => const JournalEditScreen(),
            ),
          ],
        ),

        // Profile tab
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
          routes: [
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'premium',
              name: 'premium',
              builder: (context, state) => const PremiumScreen(),
            ),
          ],
        ),
      ],
    ),

    // Social (outside shell for different navigation)
    GoRoute(
      path: AppRoutes.social,
      name: 'social',
      builder: (context, state) => const SocialScreen(),
    ),
  ],
);
