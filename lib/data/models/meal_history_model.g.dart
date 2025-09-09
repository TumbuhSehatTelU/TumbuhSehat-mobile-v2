// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealHistoryModel _$MealHistoryModelFromJson(Map<String, dynamic> json) =>
    MealHistoryModel(
      timestamp: (json['timestamp'] as num).toInt(),
      eaters: EatersModel.fromJson(json['eaters'] as Map<String, dynamic>),
      components: (json['components'] as List<dynamic>)
          .map((e) => MealComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MealHistoryModelToJson(MealHistoryModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'eaters': instance.eaters.toJson(),
      'components': instance.components.map((e) => e.toJson()).toList(),
    };

EatersModel _$EatersModelFromJson(Map<String, dynamic> json) => EatersModel(
  parentIds: (json['parent_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  childIds: (json['child_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$EatersModelToJson(EatersModel instance) =>
    <String, dynamic>{
      'parent_ids': instance.parentIds,
      'child_ids': instance.childIds,
    };

MealComponentModel _$MealComponentModelFromJson(Map<String, dynamic> json) =>
    MealComponentModel(
      foodName: json['food_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      urtName: json['urt_name'] as String,
      totalGrams: (json['total_grams'] as num).toDouble(),
    );

Map<String, dynamic> _$MealComponentModelToJson(MealComponentModel instance) =>
    <String, dynamic>{
      'food_name': instance.foodName,
      'quantity': instance.quantity,
      'urt_name': instance.urtName,
      'total_grams': instance.totalGrams,
    };
