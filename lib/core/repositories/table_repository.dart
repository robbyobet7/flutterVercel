import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/table.dart';

class TableRepository {
  // In-memory cache of tables
  List<TableModel> _tables = [];
  bool _isInitialized = false;

  // Singleton pattern
  TableRepository._();
  static final TableRepository _instance = TableRepository._();
  static TableRepository get instance => _instance;

  // Initialize the repository with data from the JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/tables.json');
      _tables = TableModel.parseTables(jsonString);
      _isInitialized = true;
    } catch (e) {
      _tables = [];
      print('Error initializing table repository: $e');
    }
  }

  // Get all tables
  Future<List<TableModel>> getAllTables() async {
    if (!_isInitialized) await initialize();
    return _tables;
  }

  // Get table by ID
  Future<TableModel?> getTableById(int id) async {
    if (!_isInitialized) await initialize();
    try {
      return _tables.firstWhere(
        (table) => table.id == id,
        orElse: () => throw Exception('Table not found with ID: $id'),
      );
    } catch (e) {
      print('Error getting table: $e');
      return null;
    }
  }

  // Search tables by name
  Future<List<TableModel>> searchTablesByName(String query) async {
    if (!_isInitialized) await initialize();
    final lowercaseQuery = query.toLowerCase();
    return _tables
        .where(
          (table) => table.tableName.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Add a new table
  Future<TableModel> addTable(TableModel table) async {
    if (!_isInitialized) await initialize();

    // Assign a new ID if none provided
    final newTable =
        table.id == 0
            ? table.copyWith(
              id: _getNextTableId(),
              key: _tables.length,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
            : table;

    _tables.add(newTable);
    return newTable;
  }

  // Update an existing table
  Future<TableModel> updateTable(TableModel updatedTable) async {
    if (!_isInitialized) await initialize();

    final index = _tables.indexWhere((t) => t.id == updatedTable.id);

    if (index == -1) {
      throw Exception('Table not found with ID: ${updatedTable.id}');
    }

    final table = updatedTable.copyWith(updatedAt: DateTime.now());

    _tables[index] = table;
    return table;
  }

  // Delete a table
  Future<void> deleteTable(int id) async {
    if (!_isInitialized) await initialize();

    final index = _tables.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Table not found with ID: $id');
    }

    _tables.removeAt(index);
  }

  // Get tables with open bills
  Future<List<TableModel>> getTablesWithOpenBills() async {
    if (!_isInitialized) await initialize();
    return _tables.where((t) => t.countBillOpen > 0).toList();
  }

  // Get active tables
  Future<List<TableModel>> getActiveTables() async {
    if (!_isInitialized) await initialize();
    return _tables.where((t) => t.status == 1).toList();
  }

  // Generate the next available table ID
  int _getNextTableId() {
    if (_tables.isEmpty) return 1;
    return _tables.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Save tables to JSON
  Future<void> saveTablesToJson() async {
    // This is just a placeholder - in a real app, you would save to a database or file
    final jsonList = _tables.map((t) => t.toJson()).toList();
    final jsonString = json.encode(jsonList);

    // Here you might write to a file, API or database
    print('Tables would be saved to backend: ${jsonList.length} tables');
  }
}
