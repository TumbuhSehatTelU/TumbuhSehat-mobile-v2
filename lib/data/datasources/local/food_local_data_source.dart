import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database_helper.dart';
import '../../models/child_model.dart';
import '../../models/food_model.dart';
import '../../models/meal_history_model.dart';
import '../../models/parent_model.dart';
import '../../models/urt_model.dart';

abstract class FoodLocalDataSource {
  Future<List<FoodModel>> searchFoods(String query);
  Future<List<UrtModel>> getUrtsForFood(int foodId);
  Future<void> saveMealHistory(
    MealHistoryModel history,
    List<ParentModel> parents,
    List<ChildModel> children,
  );
  Future<void> saveRecommendationOverride(
    String key,
    Map<String, int> overrides,
  );
  Future<Map<String, int>> getRecommendationOverrides(String key);
}

class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  final DatabaseHelper dbHelper;
  final SharedPreferences sharedPreferences;

  FoodLocalDataSourceImpl({
    required this.dbHelper,
    required this.sharedPreferences,
  });

  @override
  Future<List<FoodModel>> searchFoods(String query) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 20,
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<UrtModel>> getUrtsForFood(int foodId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT T2.*
      FROM food_serving_options AS T1
      INNER JOIN urt_conversions AS T2 ON T1.urt_id = T2.id
      WHERE T1.food_id = ?
    ''',
      [foodId],
    );

    return List.generate(maps.length, (i) {
      return UrtModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> saveMealHistory(
    MealHistoryModel history,
    List<ParentModel> parents,
    List<ChildModel> children,
  ) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      final int mealHistoryId = await txn.insert('meal_histories', {
        'timestamp': history.timestamp,
        'is_synced': 0,
      });

      for (final component in history.components) {
        await txn.insert('meal_components', {
          'meal_history_id': mealHistoryId,
          'food_name': component.foodName,
          'quantity': component.quantity,
          'urt_name': component.urtName,
          'total_grams': component.totalGrams,
        });
      }

      for (final parent in parents) {
        await txn.insert('meal_eaters', {
          'meal_history_id': mealHistoryId,
          'parent_name': parent.name,
        });
      }

      for (final child in children) {
        await txn.insert('meal_eaters', {
          'meal_history_id': mealHistoryId,
          'child_name': child.name,
        });
      }
    });
  }

  @override
  Future<void> saveRecommendationOverride(
    String key,
    Map<String, int> overrides,
  ) async {
    final jsonString = json.encode(overrides);
    await sharedPreferences.setString(key, jsonString);
  }

  @override
  Future<Map<String, int>> getRecommendationOverrides(String key) async {
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      final decodedMap = json.decode(jsonString) as Map<String, dynamic>;
      return decodedMap.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }
}
