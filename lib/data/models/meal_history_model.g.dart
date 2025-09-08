// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealHistoryModel _$MealHistoryModelFromJson(Map<String, dynamic> json) =>
    MealHistoryModel(
      familyUniqueCode: json['familyUniqueCode'] as String,
      mealTimestamp: json['mealTimestamp'] as String,
      eaters: EatersModel.fromJson(json['eaters'] as Map<String, dynamic>),
      mealComponents: (json['mealComponents'] as List<dynamic>)
          .map((e) => MealComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalNutritions: TotalNutritionsModel.fromJson(
        json['totalNutritions'] as Map<String, dynamic>,
      ),
      analysisMethod: json['analysisMethod'] as String,
    );

Map<String, dynamic> _$MealHistoryModelToJson(MealHistoryModel instance) =>
    <String, dynamic>{
      'familyUniqueCode': instance.familyUniqueCode,
      'mealTimestamp': instance.mealTimestamp,
      'eaters': instance.eaters.toJson(),
      'mealComponents': instance.mealComponents.map((e) => e.toJson()).toList(),
      'totalNutritions': instance.totalNutritions.toJson(),
      'analysisMethod': instance.analysisMethod,
    };

EatersModel _$EatersModelFromJson(Map<String, dynamic> json) => EatersModel(
  parents: (json['parents'] as List<dynamic>)
      .map((e) => ParentEaterModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  children: (json['children'] as List<dynamic>)
      .map((e) => ChildEaterModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EatersModelToJson(EatersModel instance) =>
    <String, dynamic>{
      'parents': instance.parents.map((e) => e.toJson()).toList(),
      'children': instance.children.map((e) => e.toJson()).toList(),
    };

ParentEaterModel _$ParentEaterModelFromJson(Map<String, dynamic> json) =>
    ParentEaterModel(
      name: json['name'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$ParentEaterModelToJson(ParentEaterModel instance) =>
    <String, dynamic>{'name': instance.name, 'role': instance.role};

ChildEaterModel _$ChildEaterModelFromJson(Map<String, dynamic> json) =>
    ChildEaterModel(
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
    );

Map<String, dynamic> _$ChildEaterModelToJson(ChildEaterModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth,
    };

MealComponentModel _$MealComponentModelFromJson(Map<String, dynamic> json) =>
    MealComponentModel(
      foodName: json['foodName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      urtName: json['urtName'] as String,
      massInGrams: (json['massInGrams'] as num).toDouble(),
      nutritions: NutritionsModel.fromJson(
        json['nutritions'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MealComponentModelToJson(MealComponentModel instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'quantity': instance.quantity,
      'urtName': instance.urtName,
      'massInGrams': instance.massInGrams,
      'nutritions': instance.nutritions.toJson(),
    };

NutritionsModel _$NutritionsModelFromJson(Map<String, dynamic> json) =>
    NutritionsModel(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionsModelToJson(NutritionsModel instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carbohydrates': instance.carbohydrates,
    };

TotalNutritionsModel _$TotalNutritionsModelFromJson(
  Map<String, dynamic> json,
) => TotalNutritionsModel(
  calories: (json['calories'] as num).toDouble(),
  protein: (json['protein'] as num).toDouble(),
  fat: (json['fat'] as num).toDouble(),
  carbohydrates: (json['carbohydrates'] as num).toDouble(),
);

Map<String, dynamic> _$TotalNutritionsModelToJson(
  TotalNutritionsModel instance,
) => <String, dynamic>{
  'calories': instance.calories,
  'protein': instance.protein,
  'fat': instance.fat,
  'carbohydrates': instance.carbohydrates,
};
