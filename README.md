# Rebill POS

A Flutter app with Riverpod for state management following a feature-first architecture.

## Architecture

This project follows a feature-first architecture, which organizes code by features rather than by technical concerns. The architecture is designed to make the app scalable and maintainable.

### Project Structure

```
lib/
├── core/               # Core functionality used across the app
│   ├── constants/      # App-wide constants
│   ├── theme/          # Theme configuration
│   ├── utils/          # Utility functions and classes
│   └── widgets/        # Shared widgets used across features
├── features/           # Feature modules
│   ├── auth/           # Authentication feature
│   │   ├── data/       # Data layer (repositories, data sources)
│   │   ├── domain/     # Domain layer (entities, use cases)
│   │   └── presentation/ # UI layer (pages, widgets, providers)
│   ├── home/           # Home feature
│   └── settings/       # Settings feature
├── shared/             # Shared functionality between features
└── main.dart           # Entry point
```

## State Management

This project uses Riverpod for state management. Riverpod provides:

- Dependency injection
- State management
- Side-effect handling
- Provider composition

## Theming

The app supports both light and dark themes, which can be toggled in the settings. The theme configuration is stored in `core/theme/app_theme.dart`.

## Routing

Routing is implemented using GoRouter, which provides a declarative approach to routing. Routes are defined in `core/utils/router.dart`.

## Getting Started

### Prerequisites

- Flutter (latest stable version)
- Dart (latest stable version)

### Installation

1. Clone the repository
2. Install dependencies:
```
flutter pub get
```
3. Run the app:
```
flutter run
```

## Dependencies

- flutter_riverpod: State management
- hooks_riverpod: Hooks integration with Riverpod
- flutter_hooks: Simplify stateful logic
- go_router: Routing
- shared_preferences: Local storage
- dio: HTTP client for API requests
