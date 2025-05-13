# Rebill POS

A Flutter Point of Sale application.

## Architecture Documentation

This document outlines the standardized architecture for the Rebill POS application, including the relationship between repositories and middleware components.

### Core Architecture

The application follows a layered architecture with the following components:

1. **Models**: Data structures that represent domain entities
2. **Repositories**: Business logic and data manipulation
3. **Middleware**: Data access, caching, and reactive streams
4. **Providers**: State management using Riverpod
5. **UI Components**: Presentation layer

### Repository and Middleware Pattern

We use a standardized pattern for repository and middleware components based on feature complexity:

#### High Complexity Features (Separate Repository and Middleware)

For complex features with multiple operations and reactive UI requirements, we separate responsibilities:

**Repository Responsibilities:**
- Business logic and data manipulation
- CRUD operations on in-memory data
- Data filtering and transformation
- No direct I/O operations (file loading, network requests)
- Synchronous methods that operate on in-memory data
- Initialization state management with isInitialized flag

**Middleware Responsibilities:**
- Data access (loading from files, API calls)
- Caching mechanisms
- Stream controllers for reactive updates
- Error handling and broadcasting
- Initialize and refresh logic to keep UI up-to-date

Examples: Bills, Tables, Table-Bills, Customers

#### Medium to Low Complexity Features (Merged Repository)

For simpler features, we use a merged approach where the repository handles both data access and business logic:

**Merged Repository Responsibilities:**
- Data access and loading
- Business logic and CRUD operations
- Stream controllers for reactive updates (if needed)
- Simpler error handling
- Initialization state management with isInitialized flag

Examples: Products, Reservations

### Standardized Implementation Details

1. **Singleton Pattern**:
   All repositories and middleware use the singleton pattern to ensure a single instance throughout the app.

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

2. **Repository Initialization**:
   All repositories track their initialization state and throw exceptions when methods are called before initialization.

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

3. **Middleware JSON Loading**:
   All middleware classes handle JSON loading and repository initialization.

   ```dart
   Future<void> initialize() async {
     try {
       if (!_repository.isInitialized) {
         await _loadDataFromJson();
       }
       refreshData();
     } catch (e) {
       _errorController.add('Failed to initialize data: $e');
     }
   }
   
   Future<void> _loadDataFromJson() async {
     try {
       final jsonString = await rootBundle.loadString('assets/data.json');
       final data = Model.parseData(jsonString);
       _repository.setData(data);
     } catch (e) {
       _errorController.add('Failed to load data from JSON: $e');
     }
   }
   ```

4. **Stream Controllers**:
   Components that require reactive updates expose streams that UI components can listen to.

   ```dart
   final _dataStreamController = StreamController<List<Model>>.broadcast();
   final _errorController = StreamController<String>.broadcast();
   
   Stream<List<Model>> get dataStream => _dataStreamController.stream;
   Stream<String> get errorStream => _errorController.stream;
   ```

5. **Error Handling**:
   All data access operations include proper error handling with descriptive error messages.

   ```dart
   Future<void> someOperation() async {
     try {
       // operation code
     } catch (e) {
       _errorController.add('Failed to perform operation: $e');
     }
   }
   ```

6. **Resource Disposal**:
   All stream controllers are properly disposed.

   ```dart
   void dispose() {
     _dataStreamController.close();
     _errorController.close();
   }
   ```

7. **Serialization Support**:
   All repositories provide methods for serialization.

   ```dart
   List<Map<String, dynamic>> getDataForSerialization() {
     if (!_isInitialized) {
       throw Exception('Repository not initialized');
     }
     return _data.map((item) => item.toJson()).toList();
   }
   ```

### Code Example: Separate Repository and Middleware

```dart
// Repository (lib/core/repositories/table_repository.dart)
class TableRepository {
  // Singleton pattern
  static final TableRepository _instance = TableRepository._();
  static TableRepository get instance => _instance;
  TableRepository._();

  // Data and state management
  List<TableModel> _tables = [];
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Set data from middleware
  void setTables(List<TableModel> tables) {
    _tables = tables;
    _isInitialized = true;
  }

  // Business logic
  List<TableModel> getAllTables() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables;
  }

  // Serialization support
  List<Map<String, dynamic>> getTablesForSerialization() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.map((t) => t.toJson()).toList();
  }
}

// Middleware (lib/core/middleware/table_middleware.dart)
class TableMiddleware {
  // Singleton pattern
  static final TableMiddleware _instance = TableMiddleware._internal();
  factory TableMiddleware() => _instance;
  
  // Repository dependency
  final TableRepository _repository;
  TableMiddleware._internal() : _repository = TableRepository.instance;
  
  // Stream controllers
  final _tableStreamController = StreamController<List<TableModel>>.broadcast();
  final _tableErrorController = StreamController<String>.broadcast();
  
  // Public streams
  Stream<List<TableModel>> get tablesStream => _tableStreamController.stream;
  Stream<String> get errorStream => _tableErrorController.stream;
  
  // Initialize middleware
  Future<void> initialize() async {
    try {
      if (!_repository.isInitialized) {
        await _loadTablesFromJson();
      }
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to initialize table data: $e');
    }
  }
  
  // Load data from JSON
  Future<void> _loadTablesFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/tables.json');
      final tables = TableModel.parseTables(jsonString);
      _repository.setTables(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables from JSON: $e');
    }
  }
  
  // Refresh and broadcast data
  Future<void> refreshTables() async {
    try {
      final tables = _repository.getAllTables();
      _tableStreamController.add(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables: $e');
    }
  }
  
  // Clean up resources
  void dispose() {
    _tableStreamController.close();
    _tableErrorController.close();
  }
}
```

### Code Example: Merged Repository

```dart
// Merged Repository (lib/core/repositories/product_repository.dart)
class ProductRepository {
  // Singleton pattern
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();
  
  // Data and state management
  List<Product>? _products;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Stream controllers
  final _productStreamController = StreamController<List<Product>>.broadcast();
  final _productErrorController = StreamController<String>.broadcast();
  
  // Public streams
  Stream<List<Product>> get productsStream => _productStreamController.stream;
  Stream<String> get errorStream => _productErrorController.stream;
  
  // Initialize repository
  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadProducts();
  }
  
  // Load data from JSON
  Future<List<Product>> loadProducts() async {
    if (_products != null) {
      return _products!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/product.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parse JSON data
      if (jsonData.containsKey('products') && jsonData['products'] is List) {
        _products = (jsonData['products'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      } else {
        _products = (jsonData as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
      
      _isInitialized = true;
      _productStreamController.add(_products!);
      return _products!;
    } catch (e) {
      _productErrorController.add('Failed to load products: $e');
      return [];
    }
  }
  
  // Business logic methods
  Future<List<Product>> getProductsByType(String type) async {
    if (!_isInitialized) {
      await initialize();
    }
    return _products?.where((product) => product.type == type).toList() ?? [];
  }
  
  // Serialization support
  List<Map<String, dynamic>> getProductsForSerialization() {
    if (!_isInitialized) {
      throw Exception('Product repository not initialized');
    }
    return _products?.map((p) => p.toJson()).toList() ?? [];
  }
  
  // Clean up resources
  void dispose() {
    _productStreamController.close();
    _productErrorController.close();
  }
}
```

### Best Practices

1. **Consistency**: Follow the established patterns for similar features.
2. **Simplicity**: Use the simplest approach that meets the requirements.
3. **Documentation**: Document any deviations from the standard pattern.
4. **Testing**: Write unit tests for both repositories and middleware.
5. **Error Handling**: Always include proper error handling with specific error messages.
6. **Resource Management**: Always dispose stream controllers properly.
7. **Repository Initialization**: Always check if a repository is initialized before using it.

### When to Separate vs. Merge

**Consider Separation When:**
- The feature has complex business logic
- Real-time updates are critical
- Multiple components need to react to data changes
- The feature interacts with multiple data sources

**Consider Merging When:**
- The feature has simple CRUD operations
- The feature has a single data source
- Few components need access to the data
- Performance overhead of separation isn't justified

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
