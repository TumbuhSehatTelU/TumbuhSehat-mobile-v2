import 'package:json_annotation/json_annotation.dart';

import 'child_model.dart';

part 'parent_model.g.dart';

enum ParentRole {
  @JsonValue('Ayah')
  ayah,
  @JsonValue('Ibu')
  ibu,
  @JsonValue('Wali')
  wali,
  @JsonValue('Pengasuh')
  pengasuh,
  @JsonValue('Lainnya')
  lainnya,
}

enum LactationPeriod {
  @JsonValue('1 - 6 Bulan')
  oneToSixMonths,
  @JsonValue('7 - 12 Bulan')
  sevenToTwelveMonths,
  @JsonValue('none')
  none,
}

enum GestationalAge {
  @JsonValue('1 Bulan (0-4 Minggu)')
  month1,
  @JsonValue('2 Bulan (5-8 Minggu)')
  month2,
  @JsonValue('3 Bulan (9-13 Minggu)')
  month3,
  @JsonValue('4 Bulan (14-17 Minggu)')
  month4,
  @JsonValue('5 Bulan (18-22 Minggu)')
  month5,
  @JsonValue('6 Bulan (23-27 Minggu)')
  month6,
  @JsonValue('7 Bulan (28-31 Minggu)')
  month7,
  @JsonValue('8 Bulan (32-35 Minggu)')
  month8,
  @JsonValue('9 Bulan (36-40 Minggu)')
  month9,
  @JsonValue('none')
  none,
}

@JsonSerializable()
class ParentModel {
  final String name;
  final String password;
  final ParentRole role;
  final DateTime dateOfBirth;
  final double height;
  final double weight;
  final bool isLactating;
  final bool isPregnant;
  final LactationPeriod lactationPeriod;
  final GestationalAge gestationalAge;
  // IGNORE: ON BE PAYLOAD
  @JsonKey(includeToJson: false, includeFromJson: false)
  Gender? gender;

  ParentModel({
    required this.name,
    required this.password,
    required this.role,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    required this.isLactating,
    required this.isPregnant,
    required this.lactationPeriod,
    required this.gestationalAge,
    this.gender,
  });

  ParentModel copyWith({
    String? name,
    String? password,
    ParentRole? role,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
    bool? isLactating,
    bool? isPregnant,
    LactationPeriod? lactationPeriod,
    GestationalAge? gestationalAge,
    Gender? gender,
  }) {
    return ParentModel(
      name: name ?? this.name,
      password: password ?? this.password,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      isLactating: isLactating ?? this.isLactating,
      isPregnant: isPregnant ?? this.isPregnant,
      lactationPeriod: lactationPeriod ?? this.lactationPeriod,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      gender: gender ?? this.gender,
    );
  }

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParentModelToJson(this);
}
