// ignore_for_file: avoid_print

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
        name TEXT NOT NULL,
        category TEXT,
        priority INTEGER DEFAULT 0,
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
        meal_history_id INTEGER,
        group_name TEXT,
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

    // AKG
    await db.execute('''
      CREATE TABLE akg_standards (
        id INTEGER PRIMARY KEY,
        category TEXT NOT NULL,
        gender TEXT NOT NULL,
        start_month INTEGER NOT NULL,
        end_month INTEGER NOT NULL,
        calories REAL,
        protein REAL,
        fat REAL,
        carbohydrates REAL,
        fiber REAL,
        water REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE who_haz_boys (
        unit TEXT NOT NULL,
        value INTEGER NOT NULL,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL,
        PRIMARY KEY (unit, value)
      )
    ''');

    await db.execute('''
      CREATE TABLE who_haz_girls (
        unit TEXT NOT NULL,
        value INTEGER NOT NULL,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL,
        PRIMARY KEY (unit, value)
      )
    ''');

    await db.execute('''
      CREATE TABLE who_whz_boys_0_2_years (
        height_cm REAL PRIMARY KEY,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE who_whz_boys_2_5_years (
        height_cm REAL PRIMARY KEY,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE who_whz_girls_0_2_years (
        height_cm REAL PRIMARY KEY,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE who_whz_girls_2_5_years (
        height_cm REAL PRIMARY KEY,
        L REAL NOT NULL,
        M REAL NOT NULL,
        S REAL NOT NULL
      )
    ''');

    await db.execute('''
        CREATE TABLE food_aliases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alias_name TEXT NOT NULL UNIQUE,
          food_id INTEGER,
          FOREIGN KEY (food_id) REFERENCES foods(id)
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
    await _seedTableFromCSV(
      db: db,
      tableName: 'akg_standards',
      csvPath: 'assets/db/akg_standards.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_haz_boys',
      csvPath: 'assets/db/who_haz_boys.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_haz_girls',
      csvPath: 'assets/db/who_haz_girls.csv',
    );

    // Seeding Tabel WHZ
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_whz_boys_0_2_years',
      csvPath: 'assets/db/who_whz_boys_0_2_years.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_whz_boys_2_5_years',
      csvPath: 'assets/db/who_whz_boys_2_5_years.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_whz_girls_0_2_years',
      csvPath: 'assets/db/who_whz_girls_0_2_years.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'who_whz_girls_2_5_years',
      csvPath: 'assets/db/who_whz_girls_2_5_years.csv',
    );
    await _seedTableFromCSV(
      db: db,
      tableName: 'food_aliases',
      csvPath: 'assets/db/food_aliases.csv',
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

  Future<Map<String, Map<String, dynamic>>> getFoodNutrientLookup(
    List<Map<String, dynamic>> mealComponentMaps,
  ) async {
    if (mealComponentMaps.isEmpty) return {};

    final db = await database;
    final uniqueFoodNames = mealComponentMaps
        .map((m) => m['food_name'] as String)
        .toSet();

    if (uniqueFoodNames.isEmpty) return {};

    final foodNutrientMaps = await db.query(
      'foods',
      where: 'name IN (${List.filled(uniqueFoodNames.length, '?').join(',')})',
      whereArgs: uniqueFoodNames.toList(),
    );

    return {
      for (var foodMap in foodNutrientMaps) foodMap['name'] as String: foodMap,
    };
  }

  Future<void> reseedDatabase() async {
    final db = await database;
    print('[DB_HELPER] Reseeding database...');
    // Hapus data lama dari tabel statis
    await db.delete('foods');
    await db.delete('urt_conversions');
    await db.delete('food_serving_options');
    await db.delete('akg_standards');
    await db.delete('who_haz_boys');
    await db.delete('who_haz_girls');
    await db.delete('who_whz_boys_0_2_years');
    await db.delete('who_whz_boys_2_5_years');
    await db.delete('who_whz_girls_0_2_years');
    await db.delete('who_whz_girls_2_5_years');

    // Panggil ulang seeder
    await _seedDatabase(db);
    print('[DB_HELPER] Reseeding complete.');
  }
}
