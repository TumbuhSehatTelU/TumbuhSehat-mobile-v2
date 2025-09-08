import 'package:equatable/equatable.dart';

class FoodComponentModel extends Equatable {
  final int id;
  final String name;

  const FoodComponentModel({required this.id, required this.name});

  factory FoodComponentModel.fromMap(Map<String, dynamic> map) {
    return FoodComponentModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
