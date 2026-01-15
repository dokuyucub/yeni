# Day

Your life, in color.

A mood tracking app that turns daily emotions and health data into beautiful art.

## Getting Started

This project uses Flutter. To get started:

1. Install Flutter SDK from https://flutter.dev
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # Main app widget
├── core/                  # Core functionality
│   ├── config/           # App configuration
│   ├── theme/            # Theme definitions
│   ├── constants/        # App constants
│   ├── extensions/       # Dart extensions
│   └── utils/            # Utility functions
├── data/                  # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Repository pattern
│   ├── providers/        # Riverpod providers
│   └── services/         # Services (API, storage, etc.)
├── features/              # Feature modules
│   ├── splash/           # Splash screen
│   ├── onboarding/       # Onboarding flow
│   ├── auth/             # Authentication
│   ├── home/             # Home screen
│   ├── gallery/          # Art gallery
│   ├── journal/          # Journal entries
│   ├── profile/          # User profile
│   └── social/           # Social features
├── visualization/         # Art generation
│   ├── engines/          # Visualization engines
│   ├── painters/         # Custom painters
│   ├── models/           # Visualization models
│   └── utils/            # Visualization utilities
└── shared/                # Shared widgets
    ├── widgets/          # Reusable widgets
    └── dialogs/          # Dialog widgets
```

## Requirements

- Flutter SDK: >=3.0.0
- iOS: 15.0+
- Android: API 26+

## Dependencies

- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Local Storage**: sqflite, shared_preferences, flutter_secure_storage
- **Animations**: flutter_animate
- **UI**: shimmer, cached_network_image, flutter_svg
- **Utilities**: intl, uuid, equatable, path_provider
