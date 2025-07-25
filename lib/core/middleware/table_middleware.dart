import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/table.dart';

class TableMiddleware {
  List<TableModel> _tables = [];
  bool _isInitialized = false;

  void setTables(List<TableModel> tables) {
    _tables = tables;
    _isInitialized = true;
  }

  // Get all tables
  List<TableModel> getAllTables() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables;
  }

  // Get table by ID
  TableModel? getTableById(int id) {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    try {
      return _tables.firstWhere(
        (table) => table.id == id,
        orElse: () => throw Exception('Table not found with ID: $id'),
      );
    } catch (e) {
      return null;
    }
  }

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
  TableMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
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
      setTables(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables from JSON: $e');
    }
  }

  // Load and broadcast all tables
  Future<void> refreshTables() async {
    try {
      final tables = getAllTables();
      _tableStreamController.add(tables);
    } catch (e) {
      _tableErrorController.add('Failed to load tables: $e');
    }
  }

  // Get a single table by ID
  Future<TableModel?> getTable(int id) async {
    try {
      return getTableById(id);
    } catch (e) {
      _tableErrorController.add('Failed to get table with ID $id: $e');
      return null;
    }
  }

  // Get tables for serialization
  List<Map<String, dynamic>> getTablesForSerialization() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.map((t) => t.toJson()).toList();
  }

  // Save all table data
  Future<void> saveTables() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = getTablesForSerialization();
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
