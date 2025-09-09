import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'meal_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MealHistoryModel extends Equatable {
  final int timestamp;
  final EatersModel eaters;
  final List<MealComponentModel> components;

  const MealHistoryModel({
    required this.timestamp,
    required this.eaters,
    required this.components,
  });

  factory MealHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$MealHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealHistoryModelToJson(this);

  @override
  List<Object> get props => [timestamp, eaters, components];
}

@JsonSerializable()
class EatersModel extends Equatable {
  @JsonKey(name: 'parent_names')
  final List<String> parentNames;

  @JsonKey(name: 'child_names')
  final List<String> childNames;

  const EatersModel({required this.parentNames, required this.childNames});

  factory EatersModel.fromJson(Map<String, dynamic> json) =>
      _$EatersModelFromJson(json);

  Map<String, dynamic> toJson() => _$EatersModelToJson(this);

  @override
  List<Object> get props => [parentNames, childNames];
}

@JsonSerializable()
class MealComponentModel extends Equatable {
  @JsonKey(name: 'food_name')
  final String foodName;

  final double quantity;

  @JsonKey(name: 'urt_name')
  final String urtName;

  @JsonKey(name: 'total_grams')
  final double totalGrams;

  const MealComponentModel({
    required this.foodName,
    required this.quantity,
    required this.urtName,
    required this.totalGrams,
  });

  factory MealComponentModel.fromJson(Map<String, dynamic> json) =>
      _$MealComponentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealComponentModelToJson(this);

  @override
  List<Object> get props => [foodName, quantity, urtName, totalGrams];
}
