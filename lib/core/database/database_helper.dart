import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedDatabase(db);
  }

  Future<void> _createTables(Database db) async {
    // --- Tabel untuk Kamus Makanan ---
    await db.execute('''
    CREATE TABLE foods (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      calories REAL, protein REAL, fat REAL, carbohydrates REAL,
      fiber REAL, water REAL, calcium REAL, phosphorus REAL,
      iron REAL, sodium REAL, potassium REAL, copper REAL,
      zinc REAL, vit_a REAL, carotene_b REAL, carotene_total REAL,
      vit_b1 REAL, vit_b2 REAL, niacin REAL, vit_c REAL
    )
  ''');

    await db.execute('''
    CREATE TABLE urt_conversions (
      id INTEGER PRIMARY KEY,
      urt_name TEXT NOT NULL UNIQUE,
      grams REAL NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE food_serving_options (
      food_id INTEGER,
      urt_id INTEGER,
      FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE,
      FOREIGN KEY (urt_id) REFERENCES urt_conversions(id) ON DELETE CASCADE,
      PRIMARY KEY (food_id, urt_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE meal_histories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE meal_components (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      meal_history_id INTEGER NOT NULL,
      food_name TEXT NOT NULL,
      quantity REAL NOT NULL,
      urt_name TEXT NOT NULL,
      total_grams REAL NOT NULL,
      FOREIGN KEY (meal_history_id) REFERENCES meal_histories(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE meal_eaters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      meal_history_id INTEGER NOT NULL,
      parent_name TEXT,
      child_name TEXT,
      FOREIGN KEY (meal_history_id) REFERENCES meal_histories(id) ON DELETE CASCADE,
      CHECK (parent_name IS NOT NULL OR child_name IS NOT NULL)
    )
  ''');
  }

  Future<void> _seedDatabase(Database db) async {
    await _seedTableFromCSV(
      db: db,
      tableName: 'foods',
      csvPath: 'assets/db/foods.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'urt_conversions',
      csvPath: 'assets/db/urt_conversions.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'food_serving_options',
      csvPath: 'assets/db/food_serving_options.csv',
    );
  }

  Future<void> _seedTableFromCSV({
    required Database db,
    required String tableName,
    required String csvPath,
  }) async {
    final csvString = await rootBundle.loadString(csvPath);
    final lines = csvString.split('\n');
    if (lines.isEmpty) return;

    final headers = lines.first.trim().split(',');
    final batch = db.batch();

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = line.split(',');
      final row = <String, dynamic>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = num.tryParse(values[j]) ?? values[j];
      }
      batch.insert(
        tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    print('Seeded $tableName successfully.');
  }
}
