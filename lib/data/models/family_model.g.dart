// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyModel _$FamilyModelFromJson(Map<String, dynamic> json) => FamilyModel(
  phoneNumber: json['phoneNumber'] as String,
  uniqueCode: json['uniqueCode'] as String,
  parents: (json['parents'] as List<dynamic>)
      .map((e) => ParentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  children: (json['children'] as List<dynamic>)
      .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FamilyModelToJson(FamilyModel instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'uniqueCode': instance.uniqueCode,
      'parents': instance.parents.map((e) => e.toJson()).toList(),
      'children': instance.children.map((e) => e.toJson()).toList(),
    };
