part of 'meal_analysis_cubit.dart';

enum MealAnalysisStatus { initial, loading, loaded, saving, success, error }

class FoodCardData extends Equatable {
  final String id;
  final TextEditingController quantityController;
  final FoodModel? selectedFood;
  final UrtModel? selectedUrt;
  final List<UrtModel> availableUrts;
  final Map<String, double> calculatedNutrients;

  const FoodCardData({
    required this.id,
    required this.quantityController,
    this.selectedFood,
    this.selectedUrt,
    this.availableUrts = const [],
    this.calculatedNutrients = const {},
  });

  FoodCardData copyWith({
    FoodModel? selectedFood,
    UrtModel? selectedUrt,
    List<UrtModel>? availableUrts,
    Map<String, double>? calculatedNutrients,
    bool clearSelectedUrt = false,
  }) {
    return FoodCardData(
      id: id,
      quantityController: quantityController,
      selectedFood: selectedFood ?? this.selectedFood,
      selectedUrt: clearSelectedUrt ? null : (selectedUrt ?? this.selectedUrt),
      availableUrts: availableUrts ?? this.availableUrts,
      calculatedNutrients: calculatedNutrients ?? this.calculatedNutrients,
    );
  }

  @override
  List<Object?> get props => [
    id,
    selectedFood,
    selectedUrt,
    availableUrts,
    calculatedNutrients,
    quantityController.text,
  ];
}

class MealAnalysisState extends Equatable {
  final MealAnalysisStatus status;
  final List<FoodCardData> foodCards;
  final Map<String, double> totalNutrients;
  final String? errorMessage;

  const MealAnalysisState({
    this.status = MealAnalysisStatus.initial,
    this.foodCards = const [],
    this.totalNutrients = const {},
    this.errorMessage,
  });

  MealAnalysisState copyWith({
    MealAnalysisStatus? status,
    List<FoodCardData>? foodCards,
    Map<String, double>? totalNutrients,
    String? errorMessage,
  }) {
    return MealAnalysisState(
      status: status ?? this.status,
      foodCards: foodCards ?? this.foodCards,
      totalNutrients: totalNutrients ?? this.totalNutrients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, foodCards, totalNutrients, errorMessage];
}
