// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentModel _$ParentModelFromJson(Map<String, dynamic> json) => ParentModel(
  name: json['name'] as String,
  password: json['password'] as String,
  role: $enumDecode(_$ParentRoleEnumMap, json['role']),
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  height: (json['height'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
  isLactating: json['isLactating'] as bool,
  isPregnant: json['isPregnant'] as bool,
  lactationPeriod: $enumDecode(
    _$LactationPeriodEnumMap,
    json['lactationPeriod'],
  ),
  gestationalAge: $enumDecode(_$GestationalAgeEnumMap, json['gestationalAge']),
);

Map<String, dynamic> _$ParentModelToJson(ParentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'password': instance.password,
      'role': _$ParentRoleEnumMap[instance.role]!,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'height': instance.height,
      'weight': instance.weight,
      'isLactating': instance.isLactating,
      'isPregnant': instance.isPregnant,
      'lactationPeriod': _$LactationPeriodEnumMap[instance.lactationPeriod]!,
      'gestationalAge': _$GestationalAgeEnumMap[instance.gestationalAge]!,
    };

const _$ParentRoleEnumMap = {
  ParentRole.ayah: 'Ayah',
  ParentRole.ibu: 'Ibu',
  ParentRole.wali: 'Wali',
  ParentRole.pengasuh: 'Pengasuh',
  ParentRole.lainnya: 'Lainnya',
};

const _$LactationPeriodEnumMap = {
  LactationPeriod.oneToSixMonths: '1 - 6 Bulan',
  LactationPeriod.sevenToTwelveMonths: '7 - 12 Bulan',
  LactationPeriod.none: 'none',
};

const _$GestationalAgeEnumMap = {
  GestationalAge.month1: '1 Bulan (0-4 Minggu)',
  GestationalAge.month2: '2 Bulan (5-8 Minggu)',
  GestationalAge.month3: '3 Bulan (9-13 Minggu)',
  GestationalAge.month4: '4 Bulan (14-17 Minggu)',
  GestationalAge.month5: '5 Bulan (18-22 Minggu)',
  GestationalAge.month6: '6 Bulan (23-27 Minggu)',
  GestationalAge.month7: '7 Bulan (28-31 Minggu)',
  GestationalAge.month8: '8 Bulan (32-35 Minggu)',
  GestationalAge.month9: '9 Bulan (36-40 Minggu)',
  GestationalAge.none: 'none',
};
