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

  ChildModel copyWith({
    String? name,
    Gender? gender,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
  }) {
    return ChildModel(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}
