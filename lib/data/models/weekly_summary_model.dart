import 'package:equatable/equatable.dart';

import 'akg_model.dart';

class WeeklySummaryModel extends Equatable {
  final Map<String, NutrientSummary> nutrientSummaries;

  final List<DailyCaloryIntake> dailyIntakes;

  final Map<DateTime, List<MealEntry>> dailyMealEntries;

  final AkgModel akgStandard;

  const WeeklySummaryModel({
    required this.nutrientSummaries,
    required this.dailyIntakes,
    required this.dailyMealEntries,
    required this.akgStandard,
  });

  @override
  List<Object> get props => [
    nutrientSummaries,
    dailyIntakes,
    dailyMealEntries,
    akgStandard,
  ];
}

class NutrientSummary extends Equatable {
  final double totalIntake;
  final double target;

  const NutrientSummary({required this.totalIntake, required this.target});

  double get percentage => (target > 0) ? (totalIntake / target) * 100 : 0;

  @override
  List<Object> get props => [totalIntake, target];
}

class DailyCaloryIntake extends Equatable {
  final DateTime date;
  final double totalCalories;

  const DailyCaloryIntake({required this.date, required this.totalCalories});

  @override
  List<Object> get props => [date, totalCalories];
}

class MealEntry extends Equatable {
  final DateTime time;
  final double totalCalories;
  final List<MealComponentEntry> components;

  const MealEntry({
    required this.time,
    required this.totalCalories,
    required this.components,
  });

  @override
  List<Object> get props => [time, totalCalories, components];
}

class MealComponentEntry extends Equatable {
  final String foodName;
  final double calories;

  const MealComponentEntry({required this.foodName, required this.calories});

  @override
  List<Object> get props => [foodName, calories];
}