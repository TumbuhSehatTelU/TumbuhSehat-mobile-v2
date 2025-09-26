import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../injection_container.dart';
import '../../cubit/beranda/beranda_cubit.dart';
import '../../cubit/meal_analysis/meal_analysis_cubit.dart';
import '../../widgets/meal_analysis/food_input_card.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../../widgets/dialogs_and_modals/ts_success_modal.dart';
import '../main/main_screen.dart';

class ManualInputScreen extends StatefulWidget {
  final Set<ParentModel> selectedParents;
  final Set<ChildModel> selectedChildren;

  const ManualInputScreen({
    super.key,
    required this.selectedParents,
    required this.selectedChildren,
  });

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MealAnalysisCubit>()..addFoodComponent(),
      child: BlocConsumer<MealAnalysisCubit, MealAnalysisState>(
        listener: (context, state) {
          if (state.status == MealAnalysisStatus.saving) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state.status == MealAnalysisStatus.success) {
            context.read<BerandaCubit>().refreshBeranda();
            Navigator.of(context).pop();
            showTSSuccessModal(
              context: context,
              message: 'Data Makanan Berhasil Disimpan!',
              autoClose: true,
              duration: const Duration(seconds: 3),
              onClosed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
              },
            );
          } else if (state.status == MealAnalysisStatus.error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              ),
            );
          }
        },
        builder: (context, state) {
          return TSPageScaffold(
            title: 'Input Manual',
            body: Column(
              children: [
                const SizedBox(height: 24),
                _buildTotalCalories(state),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: state.foodCards.length,
                    itemBuilder: (context, index) {
                      final cardData = state.foodCards[index];
                      final cubit = context.read<MealAnalysisCubit>();
                      return FoodInputCard(
                        cardData: cardData,
                        onRemove: () => cubit.removeFoodComponent(cardData.id),
                        onSearch: (query) => cubit.foodRepository
                            .searchFoods(query)
                            .then((result) => result.fold((l) => [], (r) => r)),
                        onFoodSelected: (food) => cubit.updateFoodCard(
                          cardId: cardData.id,
                          selectedFood: food,
                        ),
                        onUrtSelected: (urt) => cubit.updateFoodCard(
                          cardId: cardData.id,
                          selectedUrt: urt,
                        ),
                        onQuantityChanged: (qty) => cubit.updateFoodCard(
                          cardId: cardData.id,
                          quantity: qty,
                        ),
                      );
                    },

                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 28);
                    },
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCalories(MealAnalysisState state) {
    final totalCalories =
        state.totalNutrients['calories']?.toStringAsFixed(0) ?? '0';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Kalori',
                style: TSFont.getStyle(context, TSFont.regular.h3),
              ),
              Text(
                '$totalCalories kal',
                style: TSFont.getStyle(context, TSFont.bold.h2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(thickness: 2),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TSButton(
            onPressed: () =>
                context.read<MealAnalysisCubit>().addFoodComponent(),
            text: 'Tambah Komponen Makanan',
            textStyle: TSFont.getStyle(
              context,
              TSFont.bold.large.withColor(TSColor.mainTosca.primary),
            ),
            backgroundColor: TSColor.monochrome.pureWhite,
            borderColor: TSColor.mainTosca.primary,
            borderWidth: 2,
            contentColor: TSColor.mainTosca.primary,
            icon: Icons.add,
            customBorderRadius: 240,
            style: ButtonStyleType.leftIcon,
          ),
          const SizedBox(height: 16),
          TSButton(
            onPressed: () {
              context.read<MealAnalysisCubit>().saveMeal(
                selectedParents: widget.selectedParents.toList(),
                selectedChildren: widget.selectedChildren.toList(),
              );
            },
            text: 'Simpan Makanan',
            textStyle: TSFont.getStyle(
              context,
              TSFont.bold.large.withColor(TSColor.monochrome.black),
            ),
            customBorderRadius: 240,
            backgroundColor: TSColor.secondaryGreen.primary,
            borderColor: Colors.transparent,
            contentColor: TSColor.monochrome.black,
          ),
        ],
      ),
    );
  }
}
