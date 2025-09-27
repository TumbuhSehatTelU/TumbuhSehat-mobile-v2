import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/prediction_model.dart';
import '../../../data/models/urt_model.dart';
import '../../../domain/repositories/food_repository.dart';
import '../../../injection_container.dart';
import '../../cubit/meal_analysis/meal_analysis_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../../widgets/meal_analysis/food_input_card.dart';

class PredictionReviewScreen extends StatefulWidget {
  final PredictionResponseModel predictionResult;
  final Set<dynamic> selectedMembers;

  const PredictionReviewScreen({
    super.key,
    required this.predictionResult,
    required this.selectedMembers,
  });

  @override
  State<PredictionReviewScreen> createState() => _PredictionReviewScreenState();
}

class _PredictionReviewScreenState extends State<PredictionReviewScreen> {
  final MealAnalysisCubit _mealAnalysisCubit = sl<MealAnalysisCubit>();
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processPredictions();
  }

  Future<void> _processPredictions() async {
    final foodRepo = sl<FoodRepository>();

    for (final component in widget.predictionResult.components) {
      if (component.confidence < 0.5) continue;

      final foodResult = await foodRepo.findFoodByAlias(component.label);
      await foodResult.fold((failure) async {}, (food) async {
        if (food != null) {
          final urtResult = await foodRepo.getUrtsForFood(food.id);
          urtResult.fold((failure) {}, (availableUrts) {
            if (availableUrts.isNotEmpty) {
              final bestMatch = _findBestUrt(component.massG, availableUrts);
              _mealAnalysisCubit.addFoodComponent();
              final newCardId = _mealAnalysisCubit.state.foodCards.last.id;
              _mealAnalysisCubit.updateFoodCard(
                cardId: newCardId,
                selectedFood: food,
                selectedUrt: bestMatch.urt,
                quantity: bestMatch.quantity.toString(),
              );
            }
          });
        }
      });
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  ({UrtModel urt, double quantity}) _findBestUrt(
    double massInGrams,
    List<UrtModel> urts,
  ) {
    if (urts.isEmpty) throw Exception('URT list cannot be empty');
    UrtModel bestUrt = urts.first;
    double smallestDifference = double.infinity;

    for (final urt in urts) {
      if (urt.grams <= 0) continue;
      final quantity = massInGrams / urt.grams;
      final difference = (quantity - quantity.round()).abs();
      if (difference < smallestDifference) {
        smallestDifference = difference;
        bestUrt = urt;
      }
    }
    final finalQuantity = massInGrams / bestUrt.grams;
    final roundedQuantity = (finalQuantity * 2).round() / 2.0;
    return (
      urt: bestUrt,
      quantity: roundedQuantity < 0.5 ? 0.5 : roundedQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mealAnalysisCubit,
      child: BlocConsumer<MealAnalysisCubit, MealAnalysisState>(
        listener: (context, state) {
          if (state.status == MealAnalysisStatus.saving) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state.status == MealAnalysisStatus.success) {
            Navigator.of(context).pop(); // Tutup dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data makanan berhasil disimpan!')),
            );
            Navigator.of(context)
              ..pop()
              ..pop(); // Kembali ke Beranda
          } else if (state.status == MealAnalysisStatus.error) {
            Navigator.of(context).pop(); // Tutup dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              ),
            );
          }
        },
        builder: (context, state) {
          return TSPageScaffold(
            title: 'Tinjau Hasil Scan',
            body: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // UI yang sama dengan ManualInputScreen
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: state.foodCards.length,
                          itemBuilder: (context, index) {
                            final cardData = state.foodCards[index];
                            return FoodInputCard(
                              cardData: cardData,
                              onRemove: () => _mealAnalysisCubit
                                  .removeFoodComponent(cardData.id),
                              onSearch: (query) => _mealAnalysisCubit
                                  .foodRepository
                                  .searchFoods(query)
                                  .then(
                                    (result) =>
                                        result.fold((l) => [], (r) => r),
                                  ),
                              onFoodSelected: (food) =>
                                  _mealAnalysisCubit.updateFoodCard(
                                    cardId: cardData.id,
                                    selectedFood: food,
                                  ),
                              onUrtSelected: (urt) =>
                                  _mealAnalysisCubit.updateFoodCard(
                                    cardId: cardData.id,
                                    selectedUrt: urt,
                                  ),
                              onQuantityChanged: (qty) =>
                                  _mealAnalysisCubit.updateFoodCard(
                                    cardId: cardData.id,
                                    quantity: qty,
                                  ),
                            );
                          },
                        ),
                      ),
                      // Tombol Aksi
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TSButton(
                              onPressed: () =>
                                  _mealAnalysisCubit.addFoodComponent(),
                              text: 'Tambah Komponen Makanan',
                              backgroundColor: Colors.white,
                              borderColor: TSColor.mainTosca.primary,
                              contentColor: TSColor.mainTosca.primary,
                            ),
                            const SizedBox(height: 16),
                            TSButton(
                              onPressed: () {
                                _mealAnalysisCubit.saveMeal(
                                  selectedParents: widget.selectedMembers
                                      .whereType<ParentModel>()
                                      .toList(),
                                  selectedChildren: widget.selectedMembers
                                      .whereType<ChildModel>()
                                      .toList(),
                                );
                              },
                              text: 'Simpan Makanan',
                              backgroundColor: TSColor.secondaryGreen.primary,
                              borderColor: Colors.transparent,
                              contentColor: TSColor.monochrome.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
