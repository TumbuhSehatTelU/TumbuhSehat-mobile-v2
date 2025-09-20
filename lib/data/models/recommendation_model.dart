import 'package:equatable/equatable.dart';

import 'daily_detail_model.dart';
import 'food_model.dart';
import 'urt_model.dart';

class RecommendationModel extends Equatable {
  final Map<MealTime, List<RecommendedFood>> meals;

  const RecommendationModel({required this.meals});

  factory RecommendationModel.empty() {
    return const RecommendationModel(meals: {});
  }

  @override
  List<Object> get props => [meals];
}

class RecommendedFood extends Equatable {
  final FoodModel food;
  final double quantity;
  final UrtModel urt;

  final List<RecommendedFood> alternatives;

  const RecommendedFood({
    required this.food,
    required this.quantity,
    required this.urt,
    this.alternatives = const [],
  });

  RecommendedFood copyWith({
    FoodModel? food,
    double? quantity,
    UrtModel? urt,
    List<RecommendedFood>? alternatives,
  }) {
    return RecommendedFood(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      urt: urt ?? this.urt,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  @override
  List<Object> get props => [food, quantity, urt, alternatives];
}
