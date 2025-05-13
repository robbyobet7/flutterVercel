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
      print('Error getting table: $e');
      return null;
    }
  }

  // Search tables by name
  List<TableModel> searchTablesByName(String query) {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    final lowercaseQuery = query.toLowerCase();
    return _tables
        .where(
          (table) => table.tableName.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Add a new table
  TableModel addTable(TableModel table) {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }

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
  TableModel updateTable(TableModel updatedTable) {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }

    final index = _tables.indexWhere((t) => t.id == updatedTable.id);

    if (index == -1) {
      throw Exception('Table not found with ID: ${updatedTable.id}');
    }

    final table = updatedTable.copyWith(updatedAt: DateTime.now());

    _tables[index] = table;
    return table;
  }

  // Delete a table
  void deleteTable(int id) {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }

    final index = _tables.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Table not found with ID: $id');
    }

    _tables.removeAt(index);
  }

  // Get tables with open bills
  List<TableModel> getTablesWithOpenBills() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.where((t) => t.countBillOpen > 0).toList();
  }

  // Get active tables
  List<TableModel> getActiveTables() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.where((t) => t.status == 1).toList();
  }

  // Generate the next available table ID
  int _getNextTableId() {
    if (_tables.isEmpty) return 1;
    return _tables.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Get tables for serialization
  List<Map<String, dynamic>> getTablesForSerialization() {
    if (!_isInitialized) {
      throw Exception('Table repository not initialized');
    }
    return _tables.map((t) => t.toJson()).toList();
  }
}
