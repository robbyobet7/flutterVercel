import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import '../models/table.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TableMiddleware {
  // State
  List<TableModel> _tables = [];
  bool _isInitialized = false;

  void setTables(List<TableModel> tables) {
    _tables = tables;
    _isInitialized = true;
  }

  // Dio and Token
  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Stream controllers for table events
  final _tableStreamController = StreamController<List<TableModel>>.broadcast();
  final _tableErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<TableModel>> get tablesStream => _tableStreamController.stream;
  Stream<String> get errorStream => _tableErrorController.stream;

  // Singleton instance
  static final TableMiddleware _instance = TableMiddleware._internal();
  factory TableMiddleware() {
    return _instance;
  }
  // Private constructor
  TableMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    if (!_isInitialized) {
      await refreshTables();
      _isInitialized = true;
    }
  }

  // Fetch tables from API
  Future<void> fecthTablesFromApi() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      if (token == null) {
        throw Exception('Staff token not found');
      }

      // Set header otoritation
      dio.options.headers['Authorization'] = token;

      // API call
      final response = await dio.get(AppConstants.tablesUrl);

      if (response.statusCode == 200) {
        final List<dynamic> tableListJson =
            response.data['data']['tables'] ?? [];
        _tables =
            tableListJson.map((json) => TableModel.fromJson(json)).toList();

        // Send new data to stream for UI
        _tableStreamController.add(_tables);
      } else {
        throw Exception(
          'Failed to load tables: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      _tableErrorController.add('Failed to load tables from JSON: $e');
    }
  }

  // Load and broadcast all tables
  Future<void> refreshTables() async {
    await fecthTablesFromApi();
  }

  // Get all tables
  List<TableModel> getAllTables() {
    if (!_isInitialized) {
      return [];
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

  // Save all table data
  Future<void> saveTables() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = getTablesForSerialization();
      // ignore: unused_local_variable
      final jsonString = json.encode(jsonList);
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
