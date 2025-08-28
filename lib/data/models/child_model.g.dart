// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
  name: json['name'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  height: (json['height'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
);

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': _$GenderEnumMap[instance.gender]!,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'height': instance.height,
      'weight': instance.weight,
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};
