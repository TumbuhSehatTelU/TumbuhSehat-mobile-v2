import 'package:equatable/equatable.dart';

class ServingSizeModel extends Equatable {
  final int id;
  final int foodComponentId;
  final String urtName;
  final double grams;
  final Map<String, dynamic> nutrients;

  const ServingSizeModel({
    required this.id,
    required this.foodComponentId,
    required this.urtName,
    required this.grams,
    required this.nutrients,
  });

  factory ServingSizeModel.fromMap(Map<String, dynamic> map) {
    final nutrientsMap = Map<String, dynamic>.from(map);
    // Remove fixed keys to isolate nutrients
    nutrientsMap.remove('id');
    nutrientsMap.remove('food_component_id');
    nutrientsMap.remove('urt_name');
    nutrientsMap.remove('grams');

    return ServingSizeModel(
      id: map['id'] as int,
      foodComponentId: map['food_component_id'] as int,
      urtName: map['urt_name'] as String,
      grams: (map['grams'] as num).toDouble(),
      nutrients: nutrientsMap,
    );
  }

  @override
  List<Object?> get props => [id, foodComponentId, urtName, grams, nutrients];
}