import '../models/table.dart';

class TableRepository {
  // In-memory cache of tables
  List<TableModel> _tables = [];
  bool _isInitialized = false;

  // Singleton pattern
  TableRepository._();
  static final TableRepository _instance = TableRepository._();
  static TableRepository get instance => _instance;

  // Set tables data (called from middleware)
  void setTables(List<TableModel> tables) {
    _tables = tables;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

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

  // Get tables for serialization
  List<Map<String, dynamic>> getTablesForSerialization() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.map((t) => t.toJson()).toList();
  }
}
