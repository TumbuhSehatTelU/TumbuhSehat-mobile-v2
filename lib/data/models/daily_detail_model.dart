// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum MealTime { Sarapan, MakanSiang, CamilanSore, MakanMalam, CamilanMalam }

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

  final Map<String, double> calculatedNutrients;

  const FoodDetail({
    required this.foodName,
    required this.totalGrams,
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
