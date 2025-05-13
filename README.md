# Rebill POS

A Flutter Point of Sale application.

## Architecture Documentation

This document outlines the standardized architecture pattern for the Rebill POS application.

### Core Architecture

The application follows a layered architecture with these key components:

1. **Models**: Data structures representing domain entities
2. **Repositories**: Business logic and data manipulation  
3. **Middleware**: Data access, caching, and reactive streams
4. **Providers**: State management using Riverpod
5. **UI Components**: Presentation layer

### Repository and Middleware Pattern

We implement two patterns based on feature complexity:

#### 1. High Complexity Features (Separate Repository and Middleware)

**Repository Responsibilities:**
- Business logic and in-memory data operations
- CRUD operations on cached data
- Data filtering and transformation
- Synchronous methods with initialization checks
- No direct I/O operations

**Middleware Responsibilities:**
- Data access (JSON loading, API calls)
- Stream management for reactive updates
- Error handling and broadcasting
- Initialization and refresh logic

**Examples:** Bills, Tables, Table-Bills, Customers

#### 2. Medium/Low Complexity Features (Merged Repository)

**Merged Repository Responsibilities:**
- Data access and loading
- Business logic and CRUD operations
- Stream controllers for reactive updates
- Error handling and initialization checks

**Examples:** Products, Reservations

### Implementation Guidelines

#### Singleton Pattern
All repositories and middleware use the singleton pattern:

```dart
// Repository
static final Repository _instance = Repository._();
static Repository get instance => _instance;
Repository._();

// Middleware
static final Middleware _instance = Middleware._internal();
factory Middleware() => _instance;
Middleware._internal() : _repository = Repository.instance;
```

#### Initialization Checks
All repositories track their initialization state:

```dart
bool _isInitialized = false;
bool get isInitialized => _isInitialized;

void setData(List<Model> data) {
  _data = data;
  _isInitialized = true;
}

List<Model> getData() {
  if (!_isInitialized) {
    throw Exception('Repository not initialized');
  }
  return _data;
}
```

#### Stream Management
Components that need reactive updates expose streams:

```dart
final _dataStreamController = StreamController<List<Model>>.broadcast();
final _errorController = StreamController<String>.broadcast();

Stream<List<Model>> get dataStream => _dataStreamController.stream;
Stream<String> get errorStream => _errorController.stream;

void dispose() {
  _dataStreamController.close();
  _errorController.close();
}
```

#### Error Handling
All operations include structured error handling:

```dart
Future<void> someOperation() async {
  try {
    // operation code
  } catch (e) {
    _errorController.add('Failed to perform operation: $e');
  }
}
```

### When to Choose Each Pattern

**Use Separate Repository-Middleware When:**
- Complex business logic is required
- Real-time UI updates are critical
- Multiple components need to react to data changes

**Use Merged Repository When:**
- The feature has simple CRUD operations
- Few components need access to the data
- Real-time updates are less critical

## Feature Organization by Pattern

### Separate Repository-Middleware Features
- **Bill Management**: Complex operations for bills
- **Table Management**: Managing restaurant tables and their status
- **Table-Bill Management**: Complex relationship between tables and bills
- **Customer Management**: Customer profiles and history

### Merged Repository Features
- **Product Management**: Product catalog and inventory
- **Reservation Management**: Table reservations and scheduling

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

## Data Flow Architecture

### Overview of Data Flow

This application follows a layered architecture for data management, which will eventually transition from local JSON files to REST API. The current data flow is:

```
JSON Files → Middleware → Repository → Providers → UI Screens
```

### Detailed Flow

1. **JSON Data Source (Temporary)** 
   - Product data is currently stored in `assets/product.json`
   - Will be replaced with REST API calls in the future
   - Example: `ProductMiddleware` loads data from JSON using `rootBundle.loadString()`

2. **Middleware Layer**
   - Acts as the data source abstraction
   - Handles parsing JSON into model objects
   - Implements caching for improved performance
   - Example: `ProductMiddleware` in `lib/core/middleware/product_middleware.dart`

3. **Repository Layer**
   - Provides a clean API for data operations
   - Communicates directly with the middleware
   - Handles business logic like filtering and data transformation
   - Example: `ProductRepository` in `lib/core/repositories/product_repository.dart`

4. **Provider Layer (Riverpod)**
   - Manages the application state using Riverpod
   - Exposes data streams to the UI
   - Handles state changes and updates
   - Provides filtering, searching, and manipulation of the data
   - Example: `availableProductsProvider`, `filteredProductsProvider` in `lib/core/providers/products_providers.dart`

5. **UI Layer (Screens & Widgets)**
   - Consumes provider data using `ref.watch()` or `Consumer` widgets
   - Renders UI components based on the state
   - Handles user interactions and dispatches actions back to providers

### Benefits of This Architecture

- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Layers can be tested in isolation
- **Maintainability**: Changes to data sources (e.g., JSON to API) only affect the middleware layer
- **Scalability**: New features can be added without changing the core architecture

### Example Data Flow

For displaying a list of products:
1. `ProductMiddleware` loads and parses JSON from `assets/product.json`
2. `ProductRepository` calls middleware to get products and applies basic transformations
3. `availableProductsProvider` exposes the product list as an async state
4. `filteredProductsProvider` filters products based on search query and category
5. UI components watch the filtered products provider and render the data

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
