import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../models/akg_model.dart';
import '../models/child_model.dart';
import '../models/daily_detail_model.dart';
import '../models/lms_model.dart';
import '../models/parent_model.dart';
import '../models/weekly_intake_model.dart';
import '../models/weekly_summary_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final DatabaseHelper dbHelper;

  NutritionRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, WeeklySummaryModel>> getWeeklySummary({
    required dynamic member,
    required DateTime endDate,
    required Duration duration,
  }) async {
    try {
      final akgStandard = await _calculateAkgForMember(member);
      if (akgStandard == null) {
        return Left(
          CacheFailure(
            'Standar AKG tidak ditemukan untuk anggota keluarga ini.',
          ),
        );
      }

      final startDate = endDate.subtract(duration);
      final db = await dbHelper.database;
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

      final summary = await _processHistoryData(
        historyMaps,
        akgStandard,
        startDate,
        endDate,
      );

      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Gagal memproses riwayat nutrisi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WeeklyIntake>>> getMonthlyTrend({
    required dynamic member,
    required DateTime month,
  }) async {
    try {
      final db = await dbHelper.database;
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

      final historyMaps = await db.query(
        'meal_histories as mh '
        'JOIN meal_eaters as me ON mh.id = me.meal_history_id '
        'JOIN meal_components as mc ON mh.id = mc.meal_history_id',
        where:
            '(me.parent_name = ? OR me.child_name = ?) AND mh.timestamp >= ? AND mh.timestamp < ?',
        whereArgs: [
          member.name,
          member.name,
          firstDayOfMonth.millisecondsSinceEpoch,
          lastDayOfMonth.add(const Duration(days: 1)).millisecondsSinceEpoch,
        ],
      );

      if (historyMaps.isEmpty) {
        return Right(
          List.generate(
            5,
            (i) => WeeklyIntake(weekNumber: i + 1, totalCalories: 0),
          ),
        );
      }

      final foodNutrientLookup = await _getFoodNutrientLookup(historyMaps, db);
      final weeklyTotals = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final map in historyMaps) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int,
        );
        final weekNumber = ((timestamp.day - 1) ~/ 7) + 1;

        final foodName = map['food_name'] as String;
        final totalGrams = (map['total_grams'] as num).toDouble();
        final foodNutrients = foodNutrientLookup[foodName];

        if (foodNutrients != null) {
          final caloriesPer100g =
              (foodNutrients['calories'] as num?)?.toDouble() ?? 0.0;
          final componentCalories = (totalGrams / 100.0) * caloriesPer100g;
          weeklyTotals.update(weekNumber, (value) => value + componentCalories);
        }
      }

      final result = weeklyTotals.entries.map((entry) {
        return WeeklyIntake(weekNumber: entry.key, totalCalories: entry.value);
      }).toList();

      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Gagal mengambil tren bulanan: $e'));
    }
  }

  @override
  Future<Either<Failure, ({DateTime? first, DateTime? last})>>
  getHistoryDateRange({required dynamic member}) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        '''
      SELECT MIN(mh.timestamp) as min_date, MAX(mh.timestamp) as max_date
      FROM meal_histories as mh
      JOIN meal_eaters as me ON mh.id = me.meal_history_id
      WHERE me.parent_name = ? OR me.child_name = ?
    ''',
        [member.name, member.name],
      );

      if (result.isEmpty) {
        return const Right((first: null, last: null));
      }

      final row = result.first;
      final minTimestamp = row['min_date'] as int?;
      final maxTimestamp = row['max_date'] as int?;

      final firstDate = minTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(minTimestamp)
          : null;
      final lastDate = maxTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(maxTimestamp)
          : null;

      return Right((first: firstDate, last: lastDate));
    } catch (e) {
      return Left(
        CacheFailure('Gagal mendapatkan rentang tanggal riwayat: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, DailyDetailModel>> getDailyConsumptionDetail({
    required dynamic member,
    required DateTime date,
  }) async {
    try {
      final db = await dbHelper.database;
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));

      final historyMaps = await db.rawQuery(
        '''
        SELECT 
          mh.timestamp,
          mc.food_name,
          mc.quantity,
          mc.urt_name,
          mc.total_grams
        FROM meal_histories as mh
        JOIN meal_eaters as me ON mh.id = me.meal_history_id
        JOIN meal_components as mc ON mh.id = mc.meal_history_id
        WHERE (me.parent_name = ? OR me.child_name = ?) 
          AND mh.timestamp >= ? 
          AND mh.timestamp < ?
        ''',
        [
          member.name,
          member.name,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );

      if (historyMaps.isEmpty) {
        return Right(DailyDetailModel.empty());
      }

      final foodNutrientLookup = await _getFoodNutrientLookup(historyMaps, db);
      final Map<MealTime, List<FoodDetail>> meals = {};

      for (final map in historyMaps) {
        final foodName = map['food_name'] as String;
        final totalGrams = (map['total_grams'] as num).toDouble();
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int,
        );
        final quantity = (map['quantity'] as num).toDouble();
        final urtName = map['urt_name'] as String;

        final foodNutrients = foodNutrientLookup[foodName];
        if (foodNutrients == null) continue;

        final calculatedNutrients = <String, double>{};
        final factor = totalGrams / 100.0;
        foodNutrients.forEach((key, value) {
          if (value is num) {
            calculatedNutrients[key] = value.toDouble() * factor;
          }
        });

        calculatedNutrients['timestamp'] = timestamp.millisecondsSinceEpoch
            .toDouble();

        final foodDetail = FoodDetail(
          foodName: foodName,
          totalGrams: totalGrams,
          quantity: quantity,
          urtName: urtName,
          calculatedNutrients: calculatedNutrients,
        );

        final mealTime = _getMealTimeFromDate(timestamp);
        meals.putIfAbsent(mealTime, () => []).add(foodDetail);
      }

      return Right(DailyDetailModel(meals: meals));
    } catch (e) {
      return Left(CacheFailure('Gagal mengambil detail konsumsi harian: $e'));
    }
  }

  // HELPER
  Future<AkgModel?> _calculateAkgForMember(dynamic member) async {
    final baseAkg = await _getBaseAkgForMember(member);
    if (baseAkg == null) return null;

    if (member is! ChildModel) {
      return baseAkg;
    }

    final child = member;
    final ageInDays = DateTime.now().difference(child.dateOfBirth).inDays;

    final haz = await _computeHAZ(ageInDays, child.height, child.gender);
    final whz = await _computeWHZ(
      ageInDays,
      child.weight,
      child.height,
      child.gender,
    );

    double extraCalories = 0;
    double extraProtein = 0;

    if (whz < -2) {
      final energyNeed = child.weight * 117.5;
      final proteinNeed = child.weight * 2.8;
      extraCalories = max(0, energyNeed - baseAkg.calories);
      extraProtein = max(0, proteinNeed - baseAkg.protein);
    }

    if (haz < -2) {
      extraCalories += baseAkg.calories * 0.13;
      extraProtein += baseAkg.protein * 0.32;
    }

    return baseAkg.copyWith(
      calories: baseAkg.calories + extraCalories,
      protein: baseAkg.protein + extraProtein,
      fat: baseAkg.fat,
      carbohydrates: baseAkg.carbohydrates,
      fiber: baseAkg.fiber,
      water: baseAkg.water,
    );
  }

  Future<AkgModel?> _getBaseAkgForMember(dynamic member) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    int ageInMonths;
    String genderString;
    String category;

    if (member is ParentModel) {
      ageInMonths = (now.difference(member.dateOfBirth).inDays / 30).floor();
      genderString = member.gender == Gender.male ? 'male' : 'female';
      category = genderString;
    } else if (member is ChildModel) {
      ageInMonths = (now.difference(member.dateOfBirth).inDays / 30).floor();
      genderString = 'unspecified';
      category = 'child';
    } else {
      return null;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'akg_standards',
      where:
          '(category = ? OR gender = ?) AND ? BETWEEN start_month AND end_month',
      whereArgs: [category, genderString, ageInMonths],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    var baseAkg = AkgModel.fromMap(maps.first);

    if (member is ParentModel) {
      if (member.isPregnant && member.gestationalAge != GestationalAge.none) {
        String pregnancyCategory;
        switch (member.gestationalAge) {
          case GestationalAge.month1:
          case GestationalAge.month2:
          case GestationalAge.month3:
            pregnancyCategory = 'pregnancy_t1';
            break;
          case GestationalAge.month4:
          case GestationalAge.month5:
          case GestationalAge.month6:
            pregnancyCategory = 'pregnancy_t2';
            break;
          default:
            pregnancyCategory = 'pregnancy_t3';
            break;
        }
        final pregMaps = await db.query(
          'akg_standards',
          where: 'category = ?',
          whereArgs: [pregnancyCategory],
        );
        if (pregMaps.isNotEmpty) {
          baseAkg += AkgModel.fromMap(pregMaps.first);
        }
      }
      if (member.isLactating &&
          member.lactationPeriod != LactationPeriod.none) {
        String lactationCategory;
        switch (member.lactationPeriod) {
          case LactationPeriod.oneToSixMonths:
            lactationCategory = 'lactation_m1_6';
            break;
          case LactationPeriod.sevenToTwelveMonths:
            lactationCategory = 'lactation_m7_12';
            break;
          default:
            lactationCategory = '';
            break;
        }
        if (lactationCategory.isNotEmpty) {
          final lactMaps = await db.query(
            'akg_standards',
            where: 'category = ?',
            whereArgs: [lactationCategory],
          );
          if (lactMaps.isNotEmpty) {
            baseAkg += AkgModel.fromMap(lactMaps.first);
          }
        }
      }
    }

    return baseAkg;
  }

  Future<WeeklySummaryModel> _processHistoryData(
    List<Map<String, dynamic>> maps,
    AkgModel akg,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Map<String, double> totalNutrientsInRange = {};
    final Map<DateTime, double> dailyTotalCalories = {};
    final Map<DateTime, List<MealEntry>> dailyMealEntries = {};

    final db = await dbHelper.database;
    final foodNutrientLookup = await _getFoodNutrientLookup(maps, db);

    for (final map in maps) {
      final foodName = map['food_name'] as String;
      final quantity = (map['quantity'] as num).toDouble();
      final urtName = map['urt_name'] as String;
      final totalGrams = (map['total_grams'] as num).toDouble();
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int,
      );

      final Map<String, dynamic>? foodNutrients = foodNutrientLookup[foodName];
      if (foodNutrients == null) continue;

      final factor = totalGrams / 100.0;
      double componentCalories = 0;

      foodNutrients.forEach((key, value) {
        if (value is num) {
          final nutrientValue = value.toDouble() * factor;
          totalNutrientsInRange.update(
            key,
            (v) => v + nutrientValue,
            ifAbsent: () => nutrientValue,
          );
          if (key == 'calories') componentCalories = nutrientValue;
        }
      });

      final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
      dailyTotalCalories.update(
        dateOnly,
        (v) => v + componentCalories,
        ifAbsent: () => componentCalories,
      );

      final mealComponent = MealComponentEntry(
        foodName: foodName,
        quantity: quantity,
        urtName: urtName,
        calories: componentCalories,
      );
      final mealList = dailyMealEntries.putIfAbsent(dateOnly, () => []);

      var existingEntry = mealList.firstWhere(
        (e) => e.time.isAtSameMomentAs(timestamp),
        orElse: () {
          final newEntry = MealEntry(
            time: timestamp,
            totalCalories: 0,
            components: [],
          );
          mealList.add(newEntry);
          return newEntry;
        },
      );
      existingEntry.components.add(mealComponent);
    }

    dailyMealEntries.forEach((date, meals) {
      for (var i = 0; i < meals.length; i++) {
        final totalMealCalories = meals[i].components.fold<double>(
          0,
          (sum, comp) => sum + comp.calories,
        );
        dailyMealEntries[date]![i] = MealEntry(
          time: meals[i].time,
          totalCalories: totalMealCalories,
          components: meals[i].components,
        );
      }
      meals.sort((a, b) => a.time.compareTo(b.time));
    });

    final numberOfDays = endDate.difference(startDate).inDays;
    final nutrientSummaries = {
      'calories': NutrientSummary(
        totalIntake: totalNutrientsInRange['calories'] ?? 0,
        target: akg.calories * numberOfDays,
      ),
      'protein': NutrientSummary(
        totalIntake: totalNutrientsInRange['protein'] ?? 0,
        target: akg.protein * numberOfDays,
      ),
      'fat': NutrientSummary(
        totalIntake: totalNutrientsInRange['fat'] ?? 0,
        target: akg.fat * numberOfDays,
      ),
      'carbohydrates': NutrientSummary(
        totalIntake: totalNutrientsInRange['carbohydrates'] ?? 0,
        target: akg.carbohydrates * numberOfDays,
      ),
      'fiber': NutrientSummary(
        totalIntake: totalNutrientsInRange['fiber'] ?? 0,
        target: akg.fiber * numberOfDays,
      ),
    };

    final dailyIntakes = List.generate(numberOfDays, (index) {
      final date = startDate.add(Duration(days: index));
      final dateOnly = DateTime(date.year, date.month, date.day);
      return DailyCaloryIntake(
        date: dateOnly,
        totalCalories: dailyTotalCalories[dateOnly] ?? 0,
      );
    });

    return WeeklySummaryModel(
      akgStandard: akg,
      nutrientSummaries: nutrientSummaries,
      dailyIntakes: dailyIntakes,
      dailyMealEntries: dailyMealEntries,
    );
  }

  Future<Map<String, Map<String, dynamic>>> _getFoodNutrientLookup(
    List<Map<String, dynamic>> maps,
    Database db,
  ) async {
    if (maps.isEmpty) return {};

    final uniqueFoodNames = maps.map((m) => m['food_name'] as String).toSet();

    final foodNutrientMaps = await db.query(
      'foods',
      where: 'name IN (${List.filled(uniqueFoodNames.length, '?').join(',')})',
      whereArgs: uniqueFoodNames.toList(),
    );

    return {
      for (var foodMap in foodNutrientMaps) foodMap['name'] as String: foodMap,
    };
  }

  Future<double> _computeHAZ(
    int ageInDays,
    double heightCm,
    Gender gender,
  ) async {
    final db = await dbHelper.database;

    final ageInWeeks = ageInDays ~/ 7;
    final ageInMonths = ageInDays ~/ 30;

    String tableName = gender == Gender.male ? 'who_haz_boys' : 'who_haz_girls';
    String unit;
    int value;

    if (ageInWeeks <= 13) {
      unit = 'week';
      value = ageInWeeks;
    } else {
      unit = 'month';
      value = ageInMonths;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'unit = ? AND value = ?',
      whereArgs: [unit, value],
      limit: 1,
    );

    if (maps.isEmpty) return 0.0;

    final lms = LmsModel.fromMap(maps.first);
    return _calculateZScore(value: heightCm, lms: lms);
  }

  Future<double> _computeWHZ(
    int ageInDays,
    double weightKg,
    double heightCm,
    Gender gender,
  ) async {
    final db = await dbHelper.database;

    final roundedHeight = (heightCm * 2).round() / 2;

    final ageInYears = ageInDays / 365.25;
    String tableName;
    final genderString = gender == Gender.male ? 'boys' : 'girls';

    if (ageInYears < 2) {
      tableName = 'who_whz_${genderString}_0_2_years';
    } else {
      tableName = 'who_whz_${genderString}_2_5_years';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'height_cm = ?',
      whereArgs: [roundedHeight],
      limit: 1,
    );

    if (maps.isEmpty) return 0.0;

    final lms = LmsModel.fromMap(maps.first);
    return _calculateZScore(value: weightKg, lms: lms);
  }

  double _calculateZScore({required double value, required LmsModel lms}) {
    if (lms.l != 0) {
      return (pow((value / lms.m), lms.l) - 1) / (lms.l * lms.s);
    } else {
      return log(value / lms.m) / lms.s;
    }
  }

  MealTime _getMealTimeFromDate(DateTime time) {
    if (time.hour >= 4 && time.hour < 11) return MealTime.Sarapan;
    if (time.hour >= 11 && time.hour < 15) return MealTime.MakanSiang;
    if (time.hour >= 15 && time.hour < 18) return MealTime.CamilanSore;
    if (time.hour >= 18 && time.hour < 22) return MealTime.MakanMalam;
    return MealTime.CamilanMalam;
  }
}
