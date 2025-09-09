import 'package:json_annotation/json_annotation.dart';

part 'meal_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MealHistoryModel {
  final String familyUniqueCode;
  final String mealTimestamp;
  final EatersModel eaters;
  final List<MealComponentModel> mealComponents;
  final TotalNutritionsModel totalNutritions;

  MealHistoryModel({
    required this.familyUniqueCode,
    required this.mealTimestamp,
    required this.eaters,
    required this.mealComponents,
    required this.totalNutritions,
  });

  factory MealHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$MealHistoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealHistoryModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EatersModel {
  final List<ParentEaterModel> parents;
  final List<ChildEaterModel> children;

  EatersModel({required this.parents, required this.children});
  factory EatersModel.fromJson(Map<String, dynamic> json) =>
      _$EatersModelFromJson(json);
  Map<String, dynamic> toJson() => _$EatersModelToJson(this);
}

@JsonSerializable()
class ParentEaterModel {
  final String name;
  final String role;

  ParentEaterModel({required this.name, required this.role});
  factory ParentEaterModel.fromJson(Map<String, dynamic> json) =>
      _$ParentEaterModelFromJson(json);
  Map<String, dynamic> toJson() => _$ParentEaterModelToJson(this);
}

@JsonSerializable()
class ChildEaterModel {
  final String name;
  final String dateOfBirth;

  ChildEaterModel({required this.name, required this.dateOfBirth});
  factory ChildEaterModel.fromJson(Map<String, dynamic> json) =>
      _$ChildEaterModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChildEaterModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MealComponentModel {
  final String foodName;
  final double quantity;
  final String urtName;
  final double massInGrams;
  final NutritionsModel nutritions;

  MealComponentModel({
    required this.foodName,
    required this.quantity,
    required this.urtName,
    required this.massInGrams,
    required this.nutritions,
  });
  factory MealComponentModel.fromJson(Map<String, dynamic> json) =>
      _$MealComponentModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealComponentModelToJson(this);
}

@JsonSerializable()
class NutritionsModel {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  // Tambahkan nutrisi lain jika perlu di-submit secara spesifik

  NutritionsModel({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });
  factory NutritionsModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionsModelToJson(this);
}

@JsonSerializable()
class TotalNutritionsModel {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  TotalNutritionsModel({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });
  factory TotalNutritionsModel.fromJson(Map<String, dynamic> json) =>
      _$TotalNutritionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TotalNutritionsModelToJson(this);
}
