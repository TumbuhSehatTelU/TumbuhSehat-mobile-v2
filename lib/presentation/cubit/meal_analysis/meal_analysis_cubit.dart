import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/meal_history_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/urt_model.dart';
import '../../../domain/repositories/food_repository.dart';

part 'meal_analysis_state.dart';

class MealAnalysisCubit extends Cubit<MealAnalysisState> {
  final FoodRepository foodRepository;

  MealAnalysisCubit({required this.foodRepository})
    : super(const MealAnalysisState());

  void addFoodComponent() {
    final newCard = FoodCardData(
      id: const Uuid().v4(),
      quantityController: TextEditingController(text: '1'),
    );
    final updatedCards = List<FoodCardData>.from(state.foodCards)..add(newCard);
    emit(state.copyWith(foodCards: updatedCards));
  }

  void removeFoodComponent(String cardId) {
    final updatedCards = List<FoodCardData>.from(state.foodCards)
      ..removeWhere((card) => card.id == cardId);
    emit(state.copyWith(foodCards: updatedCards));
    _calculateTotals();
  }

  Future<void> updateFoodCard({
    required String cardId,
    FoodModel? selectedFood,
    UrtModel? selectedUrt,
    String? quantity,
  }) async {
    final cardIndex = state.foodCards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    final currentCards = List<FoodCardData>.from(state.foodCards);
    var cardToUpdate = currentCards[cardIndex];
    bool shouldClearUrt = false;

    if (selectedFood != null && selectedFood != cardToUpdate.selectedFood) {
      final urtsResult = await foodRepository.getUrtsForFood(selectedFood.id);
      urtsResult.fold(
        (failure) {
        },
        (urts) {
          cardToUpdate = cardToUpdate.copyWith(
            selectedFood: selectedFood,
            availableUrts: urts,
            clearSelectedUrt: true,
          );
          shouldClearUrt = true;
        },
      );
    }

    if (selectedUrt != null) {
      cardToUpdate = cardToUpdate.copyWith(selectedUrt: selectedUrt);
    }
    if (quantity != null) {
      cardToUpdate.quantityController.text = quantity;
    }
    if (selectedFood != null && !shouldClearUrt) {
      cardToUpdate = cardToUpdate.copyWith(selectedFood: selectedFood);
    }

    currentCards[cardIndex] = cardToUpdate;
    emit(state.copyWith(foodCards: currentCards));
    _calculateTotals();
  }

  void _calculateTotals() {
    final totalNutrients = <String, double>{};
    for (final card in state.foodCards) {
      final food = card.selectedFood;
      final urt = card.selectedUrt;
      final quantity = double.tryParse(card.quantityController.text) ?? 0.0;

      if (food != null && urt != null && quantity > 0) {
        final totalGrams = urt.grams * quantity;
        final factor = totalGrams / 100.0; // Nutrients are per 100g

        food.nutrients.forEach((key, value) {
          final nutrientValue = (value as num).toDouble() * factor;
          totalNutrients.update(
            key,
            (existing) => existing + nutrientValue,
            ifAbsent: () => nutrientValue,
          );
        });
      }
    }
    emit(state.copyWith(totalNutrients: totalNutrients));
  }

  Future<void> saveMeal({
    required List<ParentModel> selectedParents,
    required List<ChildModel> selectedChildren,
  }) async {
    emit(state.copyWith(status: MealAnalysisStatus.saving));

    final components = <MealComponentModel>[];
    for (final card in state.foodCards) {
      if (card.selectedFood != null && card.selectedUrt != null) {
        final quantity = double.tryParse(card.quantityController.text) ?? 0.0;
        if (quantity > 0) {
          components.add(
            MealComponentModel(
              foodName: card.selectedFood!.name,
              quantity: quantity,
              urtName: card.selectedUrt!.urtName,
              totalGrams: card.selectedUrt!.grams * quantity,
            ),
          );
        }
      }
    }

    if (components.isEmpty) {
      emit(
        state.copyWith(
          status: MealAnalysisStatus.error,
          errorMessage: 'Tidak ada komponen makanan untuk disimpan.',
        ),
      );
      return;
    }

    final history = MealHistoryModel(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      eaters: EatersModel(
        parentNames: selectedParents.map((p) => p.name).toList(),
        childNames: selectedChildren.map((c) => c.name).toList(),
      ),
      components: components,
    );

    final result = await foodRepository.saveMealHistory(
      history: history,
      parents: selectedParents,
      children: selectedChildren,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MealAnalysisStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: MealAnalysisStatus.success)),
    );
  }
}
