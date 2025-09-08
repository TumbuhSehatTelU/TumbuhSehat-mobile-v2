import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tumbuh_sehat.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedDatabase(db);
  }

  Future<void> _createTables(Database db) async {
    // Tabel untuk kamus nutrisi
    await db.execute('''
      CREATE TABLE nutrients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        column_name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        unit TEXT NOT NULL,
        sort_order INTEGER
      )
    ''');

    // Tabel untuk nama makanan
    await db.execute('''
      CREATE TABLE food_components (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabel utama untuk ukuran saji dan nilai gizinya
    // Dibuat secara dinamis berdasarkan data dari nutrients.csv
    final nutrientsCsvString = await rootBundle.loadString(
      'assets/database/nutrients.csv',
    );
    final nutrientsRows = const CsvToListConverter().convert(
      nutrientsCsvString,
      eol: '\n',
    );

    String servingSizesColumns = '';
    // Skip header row
    for (var i = 1; i < nutrientsRows.length; i++) {
      final row = nutrientsRows[i];
      final columnName = row[0]; // 'column_name' is the first column
      servingSizesColumns += ', $columnName REAL';
    }

    await db.execute('''
      CREATE TABLE serving_sizes (
        id INTEGER PRIMARY KEY,
        food_component_id INTEGER NOT NULL,
        urt_name TEXT NOT NULL,
        grams REAL NOT NULL
        $servingSizesColumns,
        FOREIGN KEY (food_component_id) REFERENCES food_components (id)
      )
    ''');
  }

  Future<void> _seedDatabase(Database db) async {
    await _seedTableFromCsv(
      db: db,
      csvPath: 'assets/database/nutrients.csv',
      tableName: 'nutrients',
    );
    await _seedTableFromCsv(
      db: db,
      csvPath: 'assets/database/food_components.csv',
      tableName: 'food_components',
    );
    await _seedTableFromCsv(
      db: db,
      csvPath: 'assets/database/serving_sizes.csv',
      tableName: 'serving_sizes',
    );
  }

  Future<void> _seedTableFromCsv({
    required Database db,
    required String csvPath,
    required String tableName,
  }) async {
    final csvString = await rootBundle.loadString(csvPath);
    // Pastikan eol di-set ke '\n' jika file CSV Anda menggunakan LF line endings
    final list = const CsvToListConverter().convert(csvString, eol: '\n');

    if (list.length <= 1) return; // Tidak ada data untuk di-seed

    final headerRow = list[0].map((e) => e.toString()).toList();
    final batch = db.batch();

    for (int i = 1; i < list.length; i++) {
      final row = list[i];
      final Map<String, dynamic> rowMap = {};
      for (int j = 0; j < headerRow.length; j++) {
        if (j < row.length) {
          final value = row[j];
          final num? parsedNum = num.tryParse(value.toString());
          rowMap[headerRow[j]] = parsedNum ?? value;
        }
      }
      batch.insert(tableName, rowMap);
    }
    await batch.commit(noResult: true);
  }
}