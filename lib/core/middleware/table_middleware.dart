import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
      if (!_repository.isInitialized) {
        await _loadTablesFromJson();
      }
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to initialize table data: $e');
    }
  }

  // Load tables from JSON
  Future<void> _loadTablesFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/tables.json');
      final tables = TableModel.parseTables(jsonString);
      _repository.setTables(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables from JSON: $e');
    }
  }

  // Load and broadcast all tables
  Future<void> refreshTables() async {
    try {
      final tables = _repository.getAllTables();
      _tableStreamController.add(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables: $e');
    }
  }

  // Get a single table by ID
  Future<TableModel?> getTable(int id) async {
    try {
      return _repository.getTableById(id);
    } catch (e) {
      _tableErrorController.add('Failed to get table with ID $id: $e');
      return null;
    }
  }

  // Add a new table
  Future<void> addTable(TableModel table) async {
    try {
      _repository.addTable(table);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to add table: $e');
    }
  }

  // Update an existing table
  Future<void> updateTable(TableModel table) async {
    try {
      _repository.updateTable(table);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to update table: $e');
    }
  }

  // Delete a table
  Future<void> deleteTable(int id) async {
    try {
      _repository.deleteTable(id);
      refreshTables();
    } catch (e) {
      _tableErrorController.add('Failed to delete table: $e');
    }
  }

  // Search tables by name
  Future<List<TableModel>> searchTables(String query) async {
    try {
      if (query.isEmpty) {
        return _repository.getAllTables();
      }
      return _repository.searchTablesByName(query);
    } catch (e) {
      _tableErrorController.add('Failed to search tables: $e');
      return [];
    }
  }

  // Get tables with open bills
  Future<List<TableModel>> getTablesWithOpenBills() async {
    try {
      return _repository.getTablesWithOpenBills();
    } catch (e) {
      _tableErrorController.add('Failed to get tables with open bills: $e');
      return [];
    }
  }

  // Get active tables
  Future<List<TableModel>> getActiveTables() async {
    try {
      return _repository.getActiveTables();
    } catch (e) {
      _tableErrorController.add('Failed to get active tables: $e');
      return [];
    }
  }

  // Save all table data
  Future<void> saveTables() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = _repository.getTablesForSerialization();
      // ignore: unused_local_variable
      final jsonString = json.encode(jsonList);

      // In a real app: await file.writeAsString(jsonString);
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
