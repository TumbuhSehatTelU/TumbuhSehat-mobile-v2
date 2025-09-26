// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../gen/assets.gen.dart';
import '../../cubit/recommendation/recommendation_cubit.dart';
import '../common/ts_button.dart';

class MealRecommendationCard extends StatelessWidget {
  final MealTime mealTime;
  final List<RecommendedFood> recommendedFoods;

  const MealRecommendationCard({
    super.key,
    required this.mealTime,
    required this.recommendedFoods,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendedFoods.isEmpty) return const SizedBox.shrink();

    final totalCalories = recommendedFoods.fold<double>(0, (sum, item) {
      final grams = item.quantity * item.urt.grams;
      return sum + (item.food.calories * (grams / 100.0));
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: TSShadow.shadows.weight400,
      ),
      child: Column(
        children: [
          _buildHeader(mealTime.displayName, totalCalories, context),
          Divider(
            height: 16,
            thickness: 2,
            color: TSColor.monochrome.lightGrey,
          ),
          ...List.generate(recommendedFoods.length, (index) {
            return _RecommendedFoodItem(
              recommendedFood: recommendedFoods[index],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, double calories, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TSFont.getStyle(context, TSFont.bold.h2)),
        Text(
          '${calories.toStringAsFixed(0)} kkal',
          style: getResponsiveTextStyle(
            context,
            TSFont.bold.h3.withColor(TSColor.secondaryGreen.shade500),
          ),
        ),
      ],
    );
  }
}

class _RecommendedFoodItem extends StatelessWidget {
  final RecommendedFood recommendedFood;

  const _RecommendedFoodItem({required this.recommendedFood});

  ({String label, String icon, Color color}) _getCategoryInfo() {
    final category = recommendedFood.food.nutrients['category'] as String?;
    switch (category) {
      case 'sumber_karbohidrat':
        return (
          label: 'Karbohidrat',
          icon: '🍚',
          color: TSColor.additionalColor.orange,
        );
      case 'protein_hewani':
      case 'protein_nabati':
        return (
          label: 'Protein & Lemak',
          icon: '🍗',
          color: TSColor.additionalColor.red,
        );
      case 'sayuran':
      case 'buah':
        return (
          label: 'Serat',
          icon: '🥬',
          color: TSColor.additionalColor.green,
        );
      default:
        return (
          label: 'Lainnya',
          icon: '🍴',
          color: TSColor.additionalColor.blue,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _getCategoryInfo();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${categoryInfo.icon} '),
                TextSpan(
                  text: categoryInfo.label,
                  style: getResponsiveTextStyle(
                    context,
                    TSFont.bold.h3.withColor(categoryInfo.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedFood.food.name,
                      style: TSFont.getStyle(context, TSFont.bold.body),
                    ),
                    Text(
                      '${recommendedFood.quantity.toStringAsFixed(1)} ${recommendedFood.urt.urtName}',
                      style: getResponsiveTextStyle(
                        context,
                        TSFont.regular.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TSButton(
                onPressed: () => _showAlternativesModal(context),
                text: 'Ganti',
                size: ButtonSize.small,
                style: ButtonStyleType.leftIcon,
                textStyle: getResponsiveTextStyle(
                  context,
                  TSFont.medium.body.withColor(TSColor.monochrome.black),
                ),
                svgIconPath: Assets.icons.changeIcon.path,
                backgroundColor: TSColor.secondaryGreen.shade200,
                contentColor: TSColor.monochrome.black,
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAlternativesModal(BuildContext context) {
    final cubit = context.read<RecommendationCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Pilih Pengganti untuk ${recommendedFood.food.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: recommendedFood.alternatives.length,
                      itemBuilder: (context, index) {
                        final altRec = recommendedFood.alternatives[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      altRec.food.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${altRec.quantity.toStringAsFixed(1)} ${altRec.urt.urtName}',
                                    ),
                                  ],
                                ),
                              ),

                              TSButton(
                                onPressed: () {
                                  final currentState = cubit.state;
                                  if (currentState is RecommendationLoaded) {
                                    for (var entry
                                        in currentState
                                            .recommendation
                                            .meals
                                            .entries) {
                                      final mealTime = entry.key;
                                      final foods = entry.value;
                                      final foodIndex = foods.indexWhere(
                                        (f) =>
                                            f.food.id ==
                                            recommendedFood.food.id,
                                      );
                                      if (foodIndex != -1) {
                                        cubit.replaceFood(
                                          mealTime,
                                          foodIndex,
                                          altRec,
                                        );
                                        break;
                                      }
                                    }
                                  }
                                  Navigator.of(context).pop();
                                },
                                text: 'Pilih',
                                size: ButtonSize.small,
                                backgroundColor: Colors.green,
                                contentColor: Colors.white,
                                borderColor: Colors.transparent,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  TSButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Batal',
                    backgroundColor: Colors.red,
                    contentColor: Colors.white,
                    borderColor: Colors.transparent,
                    width: double.infinity,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
