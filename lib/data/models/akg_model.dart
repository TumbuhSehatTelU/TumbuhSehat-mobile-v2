import 'package:equatable/equatable.dart';

class AkgModel extends Equatable {
  final int id;
  final String category;
  final String gender;
  final int startMonth;
  final int endMonth;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double water;

  const AkgModel({
    required this.id,
    required this.category,
    required this.gender,
    required this.startMonth,
    required this.endMonth,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    required this.water,
  });

  factory AkgModel.fromMap(Map<String, dynamic> map) {
    return AkgModel(
      id: map['id'] as int,
      category: map['category'] as String,
      gender: map['gender'] as String,
      startMonth: map['start_month'] as int,
      endMonth: map['end_month'] as int,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      carbohydrates: (map['carbohydrates'] as num).toDouble(),
      fiber: (map['fiber'] as num).toDouble(),
      water: (map['water'] as num).toDouble(),
    );
  }

  AkgModel operator +(AkgModel other) {
    return AkgModel(
      id: id,
      category: category,
      gender: gender,
      startMonth: startMonth,
      endMonth: endMonth,
      calories: calories + other.calories,
      protein: protein + other.protein,
      fat: fat + other.fat,
      carbohydrates: carbohydrates + other.carbohydrates,
      fiber: fiber + other.fiber,
      water: water + other.water,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      category,
      gender,
      startMonth,
      endMonth,
      calories,
      protein,
      fat,
      carbohydrates,
      fiber,
      water,
    ];
  }
}
