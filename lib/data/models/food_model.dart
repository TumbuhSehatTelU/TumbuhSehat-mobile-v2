import 'package:equatable/equatable.dart';

class FoodModel extends Equatable {
  final int id;
  final String name;
  final Map<String, dynamic> nutrients;

  const FoodModel({
    required this.id,
    required this.name,
    required this.nutrients,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    final nutrientsMap = Map<String, dynamic>.from(map);
    nutrientsMap.remove('id');
    nutrientsMap.remove('name');

    return FoodModel(
      id: map['id'] as int,
      name: map['name'] as String,
      nutrients: nutrientsMap,
    );
  }

  // Nutrisi Utama
  double get calories => (nutrients['calories'] as num?)?.toDouble() ?? 0.0;
  double get protein => (nutrients['protein'] as num?)?.toDouble() ?? 0.0;
  double get fat => (nutrients['fat'] as num?)?.toDouble() ?? 0.0;
  double get carbohydrates =>
      (nutrients['carbohydrates'] as num?)?.toDouble() ?? 0.0;
  double get fiber => (nutrients['fiber'] as num?)?.toDouble() ?? 0.0;
  double get water => (nutrients['water'] as num?)?.toDouble() ?? 0.0;

  // Mineral (mg)
  double get calcium => (nutrients['calcium'] as num?)?.toDouble() ?? 0.0;
  double get phosphorus => (nutrients['phosphorus'] as num?)?.toDouble() ?? 0.0;
  double get iron => (nutrients['iron'] as num?)?.toDouble() ?? 0.0;
  double get sodium => (nutrients['sodium'] as num?)?.toDouble() ?? 0.0;
  double get potassium => (nutrients['potassium'] as num?)?.toDouble() ?? 0.0;
  double get copper => (nutrients['copper'] as num?)?.toDouble() ?? 0.0;
  double get zinc => (nutrients['zinc'] as num?)?.toDouble() ?? 0.0;

  // Vitamin
  double get vitA => (nutrients['vit_a'] as num?)?.toDouble() ?? 0.0; // (mcg)
  double get caroteneB =>
      (nutrients['carotene_b'] as num?)?.toDouble() ?? 0.0; // (mcg)
  double get caroteneTotal =>
      (nutrients['carotene_total'] as num?)?.toDouble() ?? 0.0; // (mcg)
  double get vitB1 => (nutrients['vit_b1'] as num?)?.toDouble() ?? 0.0; // (mg)
  double get vitB2 => (nutrients['vit_b2'] as num?)?.toDouble() ?? 0.0; // (mg)
  double get niacin => (nutrients['niacin'] as num?)?.toDouble() ?? 0.0; // (mg)
  double get vitC => (nutrients['vit_c'] as num?)?.toDouble() ?? 0.0; // (mg)

  @override
  List<Object> get props => [id, name, nutrients];
}
