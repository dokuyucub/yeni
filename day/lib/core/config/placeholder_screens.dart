import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder screen for Splash
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splash')),
      body: const Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}

/// Placeholder screen for Onboarding
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: const Center(
        child: Text('Onboarding Screen'),
      ),
    );
  }
}

/// Main shell with bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/gallery');
        break;
      case 2:
        context.go('/journal');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current location
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      _currentIndex = 0;
    } else if (location.startsWith('/gallery')) {
      _currentIndex = 1;
    } else if (location.startsWith('/journal')) {
      _currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      _currentIndex = 3;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Placeholder screen for Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}

/// Placeholder screen for Gallery
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: const Center(
        child: Text('Gallery Screen'),
      ),
    );
  }
}

/// Placeholder screen for Artwork Detail
class ArtworkDetailScreen extends StatelessWidget {
  final String artworkId;

  const ArtworkDetailScreen({super.key, required this.artworkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artwork Detail')),
      body: Center(
        child: Text('Artwork Detail Screen\nID: $artworkId'),
      ),
    );
  }
}

/// Placeholder screen for Journal
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const Center(
        child: Text('Journal Screen'),
      ),
    );
  }
}

/// Placeholder screen for Journal Edit
class JournalEditScreen extends StatelessWidget {
  const JournalEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Edit')),
      body: const Center(
        child: Text('Journal Edit Screen'),
      ),
    );
  }
}

/// Placeholder screen for Profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}

/// Placeholder screen for Settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}

/// Placeholder screen for Premium
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: const Center(
        child: Text('Premium Screen'),
      ),
    );
  }
}

/// Placeholder screen for Social
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      body: const Center(
        child: Text('Social Screen'),
      ),
    );
  }
}
