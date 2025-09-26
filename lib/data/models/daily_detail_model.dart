// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

import 'recommendation_model.dart';

enum MealTime { Sarapan, MakanSiang, CamilanSore, MakanMalam, CamilanMalam }

extension MealTimeExtension on MealTime {
  String get displayName {
    switch (this) {
      case MealTime.MakanSiang:
        return 'Makan Siang';
      case MealTime.CamilanSore:
        return 'Camilan Sore';
      case MealTime.MakanMalam:
        return 'Makan Malam';
      case MealTime.CamilanMalam:
        return 'Camilan Malam';
      default:
        return name;
    }
  }
}

MealTime? getNextRelevantMealTime(RecommendationModel recommendation) {
  final hour = DateTime.now().hour;

  if (hour < 11 && recommendation.meals.containsKey(MealTime.Sarapan)) {
    return MealTime.Sarapan;
  }
  if (hour < 15 && recommendation.meals.containsKey(MealTime.MakanSiang)) {
    return MealTime.MakanSiang;
  }
  if (hour < 18 && recommendation.meals.containsKey(MealTime.CamilanSore)) {
    return MealTime.CamilanSore;
  }
  if (hour < 22 && recommendation.meals.containsKey(MealTime.MakanMalam)) {
    return MealTime.MakanMalam;
  }
  return null;
}

class DailyDetailModel extends Equatable {
  final Map<MealTime, List<FoodDetail>> meals;

  const DailyDetailModel({required this.meals});

  factory DailyDetailModel.empty() {
    return const DailyDetailModel(meals: {});
  }

  @override
  List<Object> get props => [meals];
}

class FoodDetail extends Equatable {
  final String foodName;
  final double totalGrams;
  final double quantity;
  final String urtName;
  final Map<String, double> calculatedNutrients;

  const FoodDetail({
    required this.foodName,
    required this.totalGrams,
    required this.quantity,
    required this.urtName,
    required this.calculatedNutrients,
  });

  double get calories => calculatedNutrients['calories'] ?? 0.0;
  double get protein => calculatedNutrients['protein'] ?? 0.0;
  double get fat => calculatedNutrients['fat'] ?? 0.0;
  double get carbohydrates => calculatedNutrients['carbohydrates'] ?? 0.0;
  double get fiber => calculatedNutrients['fiber'] ?? 0.0;

  Map<String, double> get vitamins {
    final vitaminsList = [
      'vit_a',
      'carotene_b',
      'carotene_total',
      'vit_b1',
      'vit_b2',
      'niacin',
      'vit_c',
    ];
    final Map<String, double> vitaminsMap = {};
    calculatedNutrients.forEach((key, value) {
      if (vitaminsList.contains(key)) {
        vitaminsMap[key] = value;
      }
    });
    return vitaminsMap;
  }

  Map<String, double> get minerals {
    final mineralsList = [
      'calcium',
      'phosphorus',
      'iron',
      'sodium',
      'potassium',
      'copper',
      'zinc',
    ];
    final Map<String, double> mineralsMap = {};
    calculatedNutrients.forEach((key, value) {
      if (mineralsList.contains(key)) {
        mineralsMap[key] = value;
      }
    });
    return mineralsMap;
  }

  @override
  List<Object> get props => [foodName, totalGrams, calculatedNutrients];
}
