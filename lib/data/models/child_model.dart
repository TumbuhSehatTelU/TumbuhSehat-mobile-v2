import 'package:json_annotation/json_annotation.dart';

part 'child_model.g.dart';

enum Gender { male, female }

@JsonSerializable()
class ChildModel {
  final String name;
  final Gender gender;
  final DateTime dateOfBirth;
  final double height;
  final double weight;

  const ChildModel({
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);
}
