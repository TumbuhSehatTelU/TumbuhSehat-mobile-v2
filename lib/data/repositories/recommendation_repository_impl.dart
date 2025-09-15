import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/error/failures.dart';
import '../../data/models/akg_model.dart';
import '../../data/models/daily_detail_model.dart';
import '../../data/models/food_model.dart';
import '../../data/models/recommendation_model.dart';
import '../../data/models/urt_model.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../domain/repositories/recommendation_repository.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final DatabaseHelper dbHelper;
  final NutritionRepository nutritionRepository;

  RecommendationRepositoryImpl({
    required this.dbHelper,
    required this.nutritionRepository,
  });

  @override
  Future<Either<Failure, RecommendationModel>> getMealRecommendation({
    required dynamic member,
    required DateTime forDate,
  }) async {
    try {
      final db = await dbHelper.database;

      final akgResult = await nutritionRepository.getAkgForMember(member);
      if (akgResult == null) return Left(CacheFailure('AKG tidak ditemukan.'));

      var remainingAkg = akgResult;

      final now = DateTime.now();
      if (forDate.year == now.year &&
          forDate.month == now.month &&
          forDate.day == now.day) {
        remainingAkg = await _getRemainingAkgForToday(db, member, remainingAkg);
      }

      // MEAL SLOT PERCENTAGE
      final breakfastTarget = _getMealTarget(remainingAkg, 0.25);
      final lunchTarget = _getMealTarget(remainingAkg, 0.40);
      final dinnerTarget = _getMealTarget(remainingAkg, 0.35);

      final breakfastRecs = await _generateRecsForMeal(db, breakfastTarget);
      final lunchRecs = await _generateRecsForMeal(db, lunchTarget);
      final dinnerRecs = await _generateRecsForMeal(db, dinnerTarget);

      final recommendation = RecommendationModel(
        meals: {
          MealTime.Sarapan: breakfastRecs,
          MealTime.MakanSiang: lunchRecs,
          MealTime.MakanMalam: dinnerRecs,
        },
      );

      return Right(recommendation);
    } catch (e) {
      return Left(CacheFailure('Gagal membuat rekomendasi: $e'));
    }
  }

  Future<AkgModel> _getRemainingAkgForToday(
    Database db,
    dynamic member,
    AkgModel totalAkg,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 1));

    final historyMaps = await db.query(
      'meal_histories as mh '
      'JOIN meal_eaters as me ON mh.id = me.meal_history_id '
      'JOIN meal_components as mc ON mh.id = mc.meal_history_id',
      where:
          '(me.parent_name = ? OR me.child_name = ?) AND mh.timestamp >= ? AND mh.timestamp < ?',
      whereArgs: [
        member.name,
        member.name,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
    );

    if (historyMaps.isEmpty) {
      return totalAkg;
    }

    final foodNutrientLookup = await dbHelper.getFoodNutrientLookup(
      historyMaps,
    );
    final consumedNutrients = <String, double>{};

    for (final map in historyMaps) {
      final foodName = map['food_name'] as String;
      final totalGrams = (map['total_grams'] as num).toDouble();
      final foodNutrients = foodNutrientLookup[foodName];

      if (foodNutrients != null) {
        final factor = totalGrams / 100.0;
        foodNutrients.forEach((key, value) {
          if (value is num) {
            final nutrientValue = value.toDouble() * factor;
            consumedNutrients.update(
              key,
              (v) => v + nutrientValue,
              ifAbsent: () => nutrientValue,
            );
          }
        });
      }
    }

    return totalAkg.copyWith(
      calories: max(
        0,
        totalAkg.calories - (consumedNutrients['calories'] ?? 0),
      ),
      protein: max(0, totalAkg.protein - (consumedNutrients['protein'] ?? 0)),
      fat: max(0, totalAkg.fat - (consumedNutrients['fat'] ?? 0)),
      carbohydrates: max(
        0,
        totalAkg.carbohydrates - (consumedNutrients['carbohydrates'] ?? 0),
      ),
      fiber: max(0, totalAkg.fiber - (consumedNutrients['fiber'] ?? 0)),
      water: max(0, totalAkg.water - (consumedNutrients['water'] ?? 0)),
    );
  }

  Map<String, double> _getMealTarget(AkgModel akg, double percentage) {
    return {
      'calories': akg.calories * percentage,
      'carbohydrates': akg.carbohydrates * percentage,
      'protein': akg.protein * percentage,
      'fiber': akg.fiber * percentage,
    };
  }

  Future<List<RecommendedFood>> _generateRecsForMeal(
    Database db,
    Map<String, double> target,
  ) async {
    List<RecommendedFood> recommendations = [];
    double caloriesUsed = 0;

    final carbTargetCalories = target['calories']! * 0.5;
    final carbRec = await _findFoodForNutrient(
      db,
      'sumber_karbohidrat',
      'calories',
      carbTargetCalories,
    );
    if (carbRec != null) {
      recommendations.add(carbRec);
      caloriesUsed +=
          carbRec.food.calories * (carbRec.quantity * carbRec.urt.grams / 100);
    }

    final proteinTargetCalories = target['calories']! * 0.3;
    final hewaniCandidates = await db.query(
      'foods',
      where: 'category = ? AND calories > 0',
      whereArgs: ['protein_hewani'],
      orderBy: 'priority DESC',
      limit: 3,
    );
    final nabatiCandidates = await db.query(
      'foods',
      where: 'category = ? AND calories > 0',
      whereArgs: ['protein_nabati'],
      orderBy: 'priority DESC',
      limit: 3,
    );

    final allProteinCandidates = [...hewaniCandidates, ...nabatiCandidates];
    if (allProteinCandidates.isNotEmpty) {
      allProteinCandidates.shuffle();
      final selectedFoodMap = allProteinCandidates.first;
      final selectedFood = FoodModel.fromMap(selectedFoodMap);
      final selectedCategory = selectedFoodMap['category'] as String;

      final proteinRec = await _findFoodForNutrient(
        db,
        selectedCategory,
        'calories',
        proteinTargetCalories,
        specificFoodId: selectedFood.id,
      );

      if (proteinRec != null) {
        recommendations.add(proteinRec);
        caloriesUsed +=
            proteinRec.food.calories *
            (proteinRec.quantity * proteinRec.urt.grams / 100);
      }
    }

    final fiberTargetCalories = max(50, target['calories']! - caloriesUsed);
    final fiberRec = await _findFoodForNutrient(
      db,
      'sayuran',
      'calories',
      fiberTargetCalories.roundToDouble(),
    );
    if (fiberRec != null) {
      recommendations.add(fiberRec);
    }

    return recommendations;
  }

  Future<RecommendedFood?> _findFoodForNutrient(
    Database db,
    String category,
    String targetNutrient,
    double targetValue, {
    int? specificFoodId,
  }) async {
    if (targetValue <= 0) return null;

    List<Map<String, dynamic>> mainFoodMaps;
    if (specificFoodId != null) {
      mainFoodMaps = await db.query(
        'foods',
        where: 'id = ?',
        whereArgs: [specificFoodId],
        limit: 1,
      );
    } else {
      mainFoodMaps = await db.query(
        'foods',
        where: 'category = ? AND calories > 0',
        whereArgs: [category],
        orderBy: 'priority DESC',
        limit: 1,
      );
    }
    if (mainFoodMaps.isEmpty) return null;
    final mainFood = FoodModel.fromMap(mainFoodMaps.first);

    final urtMaps = await db.rawQuery(
      'SELECT T2.* FROM food_serving_options T1 JOIN urt_conversions T2 ON T1.urt_id = T2.id WHERE T1.food_id = ?',
      [mainFood.id],
    );
    if (urtMaps.isEmpty) return null;
    final availableUrts = urtMaps.map((map) => UrtModel.fromMap(map)).toList();
    final bestUrt = availableUrts.first;

    final nutrientValuePer100g =
        (mainFood.nutrients[targetNutrient] as num?)?.toDouble() ?? 0.0;
    if (nutrientValuePer100g <= 0) return null;

    final requiredGrams = (targetValue / nutrientValuePer100g) * 100.0;
    final quantity = requiredGrams / bestUrt.grams;

    final alternatives = await _findAlternatives(db, category, mainFood.id);

    return RecommendedFood(
      food: mainFood,
      quantity: quantity.isNaN ? 1.0 : quantity,
      urt: bestUrt,
      alternatives: alternatives,
    );
  }

  Future<List<FoodModel>> _findAlternatives(
    Database db,
    String category,
    int excludeId,
  ) async {
    final maps = await db.query(
      'foods',
      where: 'category = ? AND id != ?',
      whereArgs: [category, excludeId],
      orderBy: 'priority DESC',
      limit: 3,
    );
    return maps.map((map) => FoodModel.fromMap(map)).toList();
  }
}
