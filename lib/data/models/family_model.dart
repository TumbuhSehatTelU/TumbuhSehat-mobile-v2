import 'package:json_annotation/json_annotation.dart';
import 'child_model.dart';
import 'parent_model.dart';

part 'family_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FamilyModel {
  final String phoneNumber;
  final String uniqueCode;
  final List<ParentModel> parents;
  final List<ChildModel> children;

  const FamilyModel({
    required this.phoneNumber,
    required this.uniqueCode,
    required this.parents,
    required this.children,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyModelToJson(this);

  FamilyModel copyWith({
    String? phoneNumber,
    String? uniqueCode,
    List<ParentModel>? parents,
    List<ChildModel>? children,
  }) {
    return FamilyModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      parents: parents ?? this.parents,
      children: children ?? this.children,
    );
  }
}
