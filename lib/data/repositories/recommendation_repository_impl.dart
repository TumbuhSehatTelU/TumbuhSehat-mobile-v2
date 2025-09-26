import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
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
import '../datasources/local/food_local_data_source.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final DatabaseHelper dbHelper;
  final NutritionRepository nutritionRepository;
  final FoodLocalDataSource localDataSource;

  RecommendationRepositoryImpl({
    required this.dbHelper,
    required this.nutritionRepository,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, RecommendationModel>> getMealRecommendation({
    required dynamic member,
    required DateTime forDate,
  }) async {
    try {
      final db = await dbHelper.database;

      final totalAkg = await nutritionRepository.getAkgForMember(member);
      if (totalAkg == null) return Left(CacheFailure('AKG tidak ditemukan.'));

      final baseAkg = await nutritionRepository.getBaseAkg(member);
      if (baseAkg == null) {
        return Left(CacheFailure('AKG dasar tidak ditemukan.'));
      }

      var remainingAkg = totalAkg;
      final now = DateTime.now();
      if (forDate.year == now.year &&
          forDate.month == now.month &&
          forDate.day == now.day) {
        remainingAkg = await _getRemainingAkgForToday(db, member, remainingAkg);
      }

      final dateKey = DateFormat('yyyy-MM-dd').format(forDate);
      final key = 'recommendation_overrides_${member.name}_$dateKey';
      final overrides = await localDataSource.getRecommendationOverrides(key);

      final meals = <MealTime, List<RecommendedFood>>{};

      final extraCalories = totalAkg.calories - baseAkg.calories;
      final hasExtraNutrition = extraCalories > 10; 

      AkgModel primaryMealsAkg;
      if (hasExtraNutrition) {
        primaryMealsAkg = baseAkg.copyWith(
          calories: remainingAkg.calories - extraCalories,
          protein: remainingAkg.protein - (totalAkg.protein - baseAkg.protein),
        );
      } else {
        primaryMealsAkg = remainingAkg;
      }

      meals[MealTime.Sarapan] = await _generateRecsForMeal(
        db,
        _getMealTarget(primaryMealsAkg, 0.25),
        overrides,
        MealTime.Sarapan,
      );
      meals[MealTime.MakanSiang] = await _generateRecsForMeal(
        db,
        _getMealTarget(primaryMealsAkg, 0.40),
        overrides,
        MealTime.MakanSiang,
      );
      meals[MealTime.MakanMalam] = await _generateRecsForMeal(
        db,
        _getMealTarget(primaryMealsAkg, 0.35),
        overrides,
        MealTime.MakanMalam,
      );

      if (hasExtraNutrition) {
        final extraAkg = AkgModel(
          id: 0,
          category: '',
          gender: '',
          startMonth: 0,
          endMonth: 0,
          calories: extraCalories,
          protein: totalAkg.protein - baseAkg.protein,
          fat: 0,
          carbohydrates: 0,
          fiber: 0,
          water: 0,
        );
        meals[MealTime.CamilanSore] = await _generateRecsForMeal(
          db,
          _getMealTarget(extraAkg, 1.0),
          overrides,
          MealTime.CamilanSore,
        );
      }

      return Right(RecommendationModel(meals: meals));
    } catch (e) {
      return Left(CacheFailure('Gagal membuat rekomendasi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecommendedFood>>> getAlternatives({
    required RecommendedFood originalFood,
  }) async {
    try {
      final db = await dbHelper.database;
      final categoryResult = await db.query(
        'foods',
        columns: ['category'],
        where: 'id = ?',
        whereArgs: [originalFood.food.id],
      );
      if (categoryResult.isEmpty || categoryResult.first['category'] == null) {
        return const Right([]);
      }
      final category = categoryResult.first['category'] as String;
      final originalGrams = originalFood.quantity * originalFood.urt.grams;
      final targetValue = (originalFood.food.calories / 100.0) * originalGrams;

      final maps = await db.query(
        'foods',
        where: 'category = ? AND id != ? AND calories > 0',
        whereArgs: [category, originalFood.food.id],
        orderBy: 'priority DESC',
        limit: 3,
      );
      final List<RecommendedFood> alternativeRecs = [];
      for (final map in maps) {
        final altFood = FoodModel.fromMap(map);
        final altRec = await _calculateRecommendationForFood(
          db,
          altFood,
          'calories',
          targetValue,
        );
        if (altRec != null) {
          alternativeRecs.add(altRec);
        }
      }

      return Right(alternativeRecs);
    } catch (e) {
      return Left(CacheFailure('Gagal mencari alternatif: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecommendationChoice({
    required String memberName,
    required DateTime forDate,
    required String mealIdentifier,
    required int newFoodId,
  }) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(forDate);
      final key = 'recommendation_overrides_${memberName}_$dateKey';

      final currentOverrides = await localDataSource.getRecommendationOverrides(
        key,
      );

      currentOverrides[mealIdentifier] = newFoodId;

      await localDataSource.saveRecommendationOverride(key, currentOverrides);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan pilihan rekomendasi: $e'));
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
    Map<String, int> overrides,
    MealTime mealTime,
  ) async {
    List<RecommendedFood> recommendations = [];
    double caloriesRemaining = target['calories']!;
    int foodIndex = 0;

    if (caloriesRemaining > 0) {
      final carbOverrideId = overrides['${mealTime.name}_$foodIndex'];
      final carbRec = await _findFoodForNutrient(
        db,
        'sumber_karbohidrat',
        'calories',
        caloriesRemaining * 0.5,
        specificFoodId: carbOverrideId,
      );
      if (carbRec != null) {
        recommendations.add(carbRec);
        final grams = carbRec.quantity * carbRec.urt.grams;
        caloriesRemaining -= (carbRec.food.calories * (grams / 100.0));
      }
    }
    foodIndex++;

    if (caloriesRemaining > 50) {
      final proteinOverrideId = overrides['${mealTime.name}_$foodIndex'];
      final proteinTargetCalories = caloriesRemaining * 0.6;

      if (proteinOverrideId != null) {
        final proteinRec = await _findFoodForNutrient(
          db,
          'protein',
          'calories',
          proteinTargetCalories,
          specificFoodId: proteinOverrideId,
        );
        if (proteinRec != null) recommendations.add(proteinRec);
      } else {
        final hewaniCandidates = await db.query(
          'foods',
          where: 'category = ?',
          whereArgs: ['protein_hewani'],
          orderBy: 'priority DESC',
          limit: 3,
        );
        final nabatiCandidates = await db.query(
          'foods',
          where: 'category = ?',
          whereArgs: ['protein_nabati'],
          orderBy: 'priority DESC',
          limit: 3,
        );
        final allProteinCandidates = [...hewaniCandidates, ...nabatiCandidates];

        if (allProteinCandidates.isNotEmpty) {
          allProteinCandidates.shuffle();
          final selectedFoodMap = allProteinCandidates.first;
          final proteinRec = await _findFoodForNutrient(
            db,
            selectedFoodMap['category'] as String,
            'calories',
            proteinTargetCalories,
            specificFoodId: selectedFoodMap['id'] as int,
          );
          if (proteinRec != null) recommendations.add(proteinRec);
        }
      }

      if (recommendations.length > 1) {
        final latestRec = recommendations.last;
        final grams = latestRec.quantity * latestRec.urt.grams;
        caloriesRemaining -= (latestRec.food.calories * (grams / 100.0));
      }
    }
    foodIndex++;

    if (caloriesRemaining > 50) {
      final fiberOverrideId = overrides['${mealTime.name}_$foodIndex'];
      final fiberTargetCalories = caloriesRemaining;
      final fiberRec = await _findFoodForNutrient(
        db,
        'sayuran',
        'calories',
        fiberTargetCalories,
        specificFoodId: fiberOverrideId,
      );
      if (fiberRec != null) {
        recommendations.add(fiberRec);
      }
    }
    return recommendations;
  }

  Future<RecommendedFood?> _findFoodForNutrient(
    Database db,
    String category,
    String targetNutrient, // e.g., 'calories'
    double targetValue, {
    int? specificFoodId,
  }) async {
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

    final calculatedRecommendation = await _calculateRecommendationForFood(
      db,
      mainFood,
      targetNutrient,
      targetValue,
    );
    if (calculatedRecommendation == null) return null;

    final originalGrams =
        calculatedRecommendation.quantity * calculatedRecommendation.urt.grams;
    final actualCalories =
        (calculatedRecommendation.food.calories / 100.0) * originalGrams;

    final alternatives = await _findAlternatives(
      db,
      mainFood,
      targetNutrient,
      actualCalories,
    );

    return calculatedRecommendation.copyWith(alternatives: alternatives);
  }

  double _roundToHalf(double value) {
    return (value * 2).round() / 2.0;
  }

  Future<List<RecommendedFood>> _findAlternatives(
    Database db,
    FoodModel originalFood,
    String targetNutrient,
    double targetValue,
  ) async {
    final categoryResult = await db.query(
      'foods',
      columns: ['category'],
      where: 'id = ?',
      whereArgs: [originalFood.id],
    );
    if (categoryResult.isEmpty || categoryResult.first['category'] == null) {
      return [];
    }
    final category = categoryResult.first['category'] as String;

    final maps = await db.query(
      'foods',
      where: 'category = ? AND id != ? AND calories > 0',
      whereArgs: [category, originalFood.id],
      orderBy: 'priority DESC',
      limit: 3,
    );

    final List<RecommendedFood> alternativeRecs = [];
    for (final map in maps) {
      final altFood = FoodModel.fromMap(map);
      final altRec = await _calculateRecommendationForFood(
        db,
        altFood,
        targetNutrient,
        targetValue,
      );
      if (altRec != null) {
        alternativeRecs.add(altRec);
      }
    }
    return alternativeRecs;
  }

  Future<RecommendedFood?> _calculateRecommendationForFood(
    Database db,
    FoodModel food,
    String targetNutrient,
    double targetValue,
  ) async {
    final urtMaps = await db.rawQuery(
      'SELECT T2.* FROM food_serving_options T1 JOIN urt_conversions T2 ON T1.urt_id = T2.id WHERE T1.food_id = ? ORDER BY T2.grams DESC',
      [food.id],
    );
    if (urtMaps.isEmpty) return null;
    final bestUrt = UrtModel.fromMap(urtMaps.first);

    final nutrientValuePer100g =
        (food.nutrients[targetNutrient] as num?)?.toDouble() ?? 0.0;
    if (nutrientValuePer100g <= 0) return null;

    final requiredGrams = (targetValue / nutrientValuePer100g) * 100.0;
    final rawQuantity = requiredGrams / bestUrt.grams;

    final roundedQuantity = _roundToHalf(rawQuantity);

    if (roundedQuantity < 0.5) return null;

    return RecommendedFood(
      food: food,
      quantity: roundedQuantity,
      urt: bestUrt,
      alternatives: [],
    );
  }
}
