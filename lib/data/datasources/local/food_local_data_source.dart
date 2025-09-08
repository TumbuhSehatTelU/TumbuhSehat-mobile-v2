import 'dart:convert';
import '../../../core/database/database_helper.dart';
import '../../models/food_component_model.dart';
import '../../models/meal_history_model.dart';
import '../../models/serving_size_model.dart';

abstract class FoodLocalDataSource {
  Future<List<FoodComponentModel>> searchFoods(String query);
  Future<List<ServingSizeModel>> getServingSizes(int foodId);
  Future<void> saveMealHistory(MealHistoryModel meal);
}

class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  final DatabaseHelper dbHelper;
  FoodLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<FoodComponentModel>> searchFoods(String query) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'food_components',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 20,
    );
    return List.generate(
      maps.length,
      (i) => FoodComponentModel.fromMap(maps[i]),
    );
  }

  @override
  Future<List<ServingSizeModel>> getServingSizes(int foodId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'serving_sizes',
      where: 'food_component_id = ?',
      whereArgs: [foodId],
    );
    return List.generate(maps.length, (i) => ServingSizeModel.fromMap(maps[i]));
  }

  @override
  Future<void> saveMealHistory(MealHistoryModel meal) async {
    // NOTE: Requires new table `meal_history` in DatabaseHelper
    final db = await dbHelper.database;
    await db.insert('meal_history', {
      'payload': json.encode(meal.toJson()),
      'timestamp': DateTime.parse(meal.mealTimestamp).millisecondsSinceEpoch,
      'is_synced': 0, 
    });
  }
}
