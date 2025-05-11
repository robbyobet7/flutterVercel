import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/table.dart';
import '../middleware/table_middleware.dart';

// Table state
class TableState {
  final List<TableModel> tables;
  final List<TableModel> allTables;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  TableState({
    required this.tables,
    List<TableModel>? allTables,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  }) : allTables = allTables ?? tables;

  TableState copyWith({
    List<TableModel>? tables,
    List<TableModel>? allTables,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      allTables: allTables ?? this.allTables,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Table notifier
class TableNotifier extends StateNotifier<TableState> {
  final TableMiddleware _middleware;

  TableNotifier(this._middleware) : super(TableState(tables: [])) {
    _initialize();
    _listenToTableChanges();
    _listenToErrors();
  }

  // Initialize the provider
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    await _middleware.initialize();
  }

  // Listen for table changes
  void _listenToTableChanges() {
    _middleware.tablesStream.listen((tables) {
      state = state.copyWith(
        tables: state.searchQuery.isEmpty ? tables : state.tables,
        allTables: tables,
        isLoading: false,
      );
    });
  }

  // Listen for errors
  void _listenToErrors() {
    _middleware.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });
  }

  // Refresh table list
  Future<void> refreshTables() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.refreshTables();
  }

  // Add a new table
  Future<void> addTable(TableModel table) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.addTable(table);
  }

  // Update an existing table
  Future<void> updateTable(TableModel table) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.updateTable(table);
  }

  // Delete a table
  Future<void> deleteTable(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.deleteTable(id);
  }

  // Search tables
  Future<void> searchTables(String query) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: query,
    );

    if (query.isEmpty) {
      state = state.copyWith(tables: state.allTables, isLoading: false);
      return;
    }

    final results = await _middleware.searchTables(query);
    state = state.copyWith(tables: results, isLoading: false);
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '', tables: state.allTables);
  }

  // Get table by ID
  Future<TableModel?> getTableById(int id) async {
    return await _middleware.getTable(id);
  }

  // Get tables with open bills
  Future<void> getTablesWithOpenBills() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final tablesWithBills = await _middleware.getTablesWithOpenBills();

    state = state.copyWith(tables: tablesWithBills, isLoading: false);
  }

  // Get active tables
  Future<void> getActiveTables() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final activeTables = await _middleware.getActiveTables();

    state = state.copyWith(tables: activeTables, isLoading: false);
  }

  // Save changes
  Future<void> saveChanges() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.saveTables();
    state = state.copyWith(isLoading: false);
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    // Not disposing the middleware here as it's a singleton
    super.dispose();
  }
}

// Provider definitions

// Singleton middleware provider
final tableMiddlewareProvider = Provider<TableMiddleware>((ref) {
  return TableMiddleware();
});

// Table state provider
final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  final middleware = ref.read(tableMiddlewareProvider);
  return TableNotifier(middleware);
});

// Filtered table providers
final tablesWithOpenBillsProvider = Provider<List<TableModel>>((ref) {
  final state = ref.watch(tableProvider);
  return state.tables.where((t) => t.countBillOpen > 0).toList();
});

final activeTablesProvider = Provider<List<TableModel>>((ref) {
  final state = ref.watch(tableProvider);
  return state.tables.where((t) => t.status == 1).toList();
});

final searchResultsProvider = Provider.family<List<TableModel>, String>((
  ref,
  query,
) {
  final state = ref.watch(tableProvider);
  if (query.isEmpty) return state.tables;

  return state.tables
      .where(
        (table) => table.tableName.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});
