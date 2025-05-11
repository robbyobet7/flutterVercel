import 'dart:async';
import '../models/table.dart';
import '../repositories/table_repository.dart';

class TableMiddleware {
  final TableRepository _repository;

  // Stream controllers for table events
  final _tableStreamController = StreamController<List<TableModel>>.broadcast();
  final _tableErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<TableModel>> get tablesStream => _tableStreamController.stream;
  Stream<String> get errorStream => _tableErrorController.stream;

  // Singleton instance
  static final TableMiddleware _instance = TableMiddleware._internal();

  // Factory constructor
  factory TableMiddleware() {
    return _instance;
  }

  // Private constructor
  TableMiddleware._internal() : _repository = TableRepository.instance;

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      await _repository.initialize();
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to initialize table data: $e');
    }
  }

  // Load and broadcast all tables
  Future<void> refreshTables() async {
    try {
      final tables = await _repository.getAllTables();
      _tableStreamController.add(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables: $e');
    }
  }

  // Get a single table by ID
  Future<TableModel?> getTable(int id) async {
    try {
      return await _repository.getTableById(id);
    } catch (e) {
      _tableErrorController.add('Failed to get table with ID $id: $e');
      return null;
    }
  }

  // Add a new table
  Future<void> addTable(TableModel table) async {
    try {
      await _repository.addTable(table);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to add table: $e');
    }
  }

  // Update an existing table
  Future<void> updateTable(TableModel table) async {
    try {
      await _repository.updateTable(table);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to update table: $e');
    }
  }

  // Delete a table
  Future<void> deleteTable(int id) async {
    try {
      await _repository.deleteTable(id);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to delete table: $e');
    }
  }

  // Search tables by name
  Future<List<TableModel>> searchTables(String query) async {
    try {
      if (query.isEmpty) {
        return await _repository.getAllTables();
      }
      return await _repository.searchTablesByName(query);
    } catch (e) {
      _tableErrorController.add('Failed to search tables: $e');
      return [];
    }
  }

  // Get tables with open bills
  Future<List<TableModel>> getTablesWithOpenBills() async {
    try {
      return await _repository.getTablesWithOpenBills();
    } catch (e) {
      _tableErrorController.add('Failed to get tables with open bills: $e');
      return [];
    }
  }

  // Get active tables
  Future<List<TableModel>> getActiveTables() async {
    try {
      return await _repository.getActiveTables();
    } catch (e) {
      _tableErrorController.add('Failed to get active tables: $e');
      return [];
    }
  }

  // Save all table data
  Future<void> saveTables() async {
    try {
      await _repository.saveTablesToJson();
    } catch (e) {
      _tableErrorController.add('Failed to save tables: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _tableStreamController.close();
    _tableErrorController.close();
  }
}
