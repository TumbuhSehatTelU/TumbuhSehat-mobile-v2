import 'package:dartz/dartz.dart';
import '../../core/database/database_helper.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../models/akg_model.dart';
import '../models/child_model.dart';
import '../models/parent_model.dart';
import '../models/weekly_summary_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final DatabaseHelper dbHelper;

  NutritionRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, WeeklySummaryModel>> getWeeklySummary({
    required dynamic member,
    required DateTime targetDate,
  }) async {
    try {
      final akgStandard = await _getAkgForMember(member);
      if (akgStandard == null) {
        return Left(
          CacheFailure(
            'Standar AKG tidak ditemukan untuk anggota keluarga ini.',
          ),
        );
      }

      final weekStartDate = targetDate.subtract(
        Duration(days: targetDate.weekday - 1),
      );
      final weekEndDate = weekStartDate.add(const Duration(days: 7));

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
          weekStartDate.millisecondsSinceEpoch,
          weekEndDate.millisecondsSinceEpoch,
        ],
      );

      final summary = await _processHistoryData(
        historyMaps,
        akgStandard,
        weekStartDate,
      );

      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('Gagal memproses riwayat nutrisi: $e'));
    }
  }

  Future<AkgModel?> _getAkgForMember(dynamic member) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    int ageInMonths;
    String genderString;

    if (member is ParentModel) {
      ageInMonths = (now.difference(member.dateOfBirth).inDays / 30).floor();
      genderString = member.gender == Gender.male ? 'male' : 'female';
    } else if (member is ChildModel) {
      ageInMonths = (now.difference(member.dateOfBirth).inDays / 30).floor();
      genderString = 'unspecified';
    } else {
      return null;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'akg_standards',
      where: 'gender = ? AND ? BETWEEN start_month AND end_month',
      whereArgs: [genderString, ageInMonths],
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
        if (pregMaps.isNotEmpty) baseAkg += AkgModel.fromMap(pregMaps.first);
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
          if (lactMaps.isNotEmpty) baseAkg += AkgModel.fromMap(lactMaps.first);
        }
      }
    }

    return baseAkg;
  }

  Future<WeeklySummaryModel> _processHistoryData(
    List<Map<String, dynamic>> maps,
    AkgModel akg,
    DateTime weekStart,
  ) async {
    if (maps.isEmpty) {
      return WeeklySummaryModel(
        akgStandard: akg,
        nutrientSummaries: {
          'calories': NutrientSummary(totalIntake: 0, target: akg.calories * 7),
          'protein': NutrientSummary(totalIntake: 0, target: akg.protein * 7),
          'fat': NutrientSummary(totalIntake: 0, target: akg.fat * 7),
          'carbohydrates': NutrientSummary(
            totalIntake: 0,
            target: akg.carbohydrates * 7,
          ),
          'fiber': NutrientSummary(totalIntake: 0, target: akg.fiber * 7),
        },
        dailyIntakes: List.generate(
          7,
          (i) => DailyCaloryIntake(
            date: weekStart.add(Duration(days: i)),
            totalCalories: 0,
          ),
        ),
        dailyMealEntries: {},
      );
    }

    final db = await dbHelper.database;
    final uniqueFoodNames = maps.map((m) => m['food_name'] as String).toSet();

    final foodNutrientMaps = await db.query(
      'foods',
      where: 'name IN (${List.filled(uniqueFoodNames.length, '?').join(',')})',
      whereArgs: uniqueFoodNames.toList(),
    );

    final foodNutrientLookup = {
      for (var foodMap in foodNutrientMaps) foodMap['name'] as String: foodMap,
    };

    final Map<String, double> weeklyTotalNutrients = {};
    final Map<int, double> dailyTotalCalories = {};
    final Map<DateTime, List<MealEntry>> dailyMealEntries = {};

    for (final map in maps) {
      final foodName = map['food_name'] as String;
      final totalGrams = (map['total_grams'] as num).toDouble();
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int,
      );

      final Map<String, dynamic>? foodNutrients = foodNutrientLookup[foodName];
      if (foodNutrients == null) {
        continue;
      }

      final factor = totalGrams / 100.0;
      double componentCalories = 0;
      foodNutrients.forEach((key, value) {
        if (value is num) {
          final nutrientValue = value.toDouble() * factor;
          weeklyTotalNutrients.update(
            key,
            (v) => v + nutrientValue,
            ifAbsent: () => nutrientValue,
          );
          if (key == 'calories') {
            componentCalories = nutrientValue;
          }
        }
      });

      final dayOfWeek = timestamp.weekday;
      dailyTotalCalories.update(
        dayOfWeek,
        (v) => v + componentCalories,
        ifAbsent: () => componentCalories,
      );

      final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final mealComponent = MealComponentEntry(
        foodName: foodName,
        calories: componentCalories,
      );

      var mealList = dailyMealEntries.putIfAbsent(dateOnly, () => []);
      var mealEntry = mealList.firstWhere(
        (entry) => entry.time.isAtSameMomentAs(timestamp),
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
      mealEntry.components.add(mealComponent);
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
    });

    final nutrientSummaries = {
      'calories': NutrientSummary(
        totalIntake: weeklyTotalNutrients['calories'] ?? 0,
        target: akg.calories * 7,
      ),
      'protein': NutrientSummary(
        totalIntake: weeklyTotalNutrients['protein'] ?? 0,
        target: akg.protein * 7,
      ),
      'fat': NutrientSummary(
        totalIntake: weeklyTotalNutrients['fat'] ?? 0,
        target: akg.fat * 7,
      ),
      'carbohydrates': NutrientSummary(
        totalIntake: weeklyTotalNutrients['carbohydrates'] ?? 0,
        target: akg.carbohydrates * 7,
      ),
      'fiber': NutrientSummary(
        totalIntake: weeklyTotalNutrients['fiber'] ?? 0,
        target: akg.fiber * 7,
      ),
    };

    final dailyIntakes = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return DailyCaloryIntake(
        date: date,
        totalCalories: dailyTotalCalories[date.weekday] ?? 0,
      );
    });

    return WeeklySummaryModel(
      akgStandard: akg,
      nutrientSummaries: nutrientSummaries,
      dailyIntakes: dailyIntakes,
      dailyMealEntries: dailyMealEntries,
    );
  }
}
