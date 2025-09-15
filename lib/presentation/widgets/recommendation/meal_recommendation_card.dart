// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/recommendation_model.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(mealTime.name, totalCalories),
          const Divider(height: 24),
          ...List.generate(recommendedFoods.length, (index) {
            return _RecommendedFoodItem(
              recommendedFood: recommendedFoods[index],
              onReplace: (newFood) {
                context.read<RecommendationCubit>().replaceFood(
                  mealTime,
                  index,
                  newFood,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, double calories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${calories.toStringAsFixed(0)} kkal',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _RecommendedFoodItem extends StatelessWidget {
  final RecommendedFood recommendedFood;
  final Function(RecommendedFood) onReplace;

  const _RecommendedFoodItem({
    required this.recommendedFood,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // TODO: Add category icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendedFood.food.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${recommendedFood.quantity.toStringAsFixed(1)} ${recommendedFood.urt.urtName}',
                  style: TextStyle(color: TSColor.monochrome.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TSButton(
            onPressed: () => _showAlternativesModal(context),
            text: 'Ganti',
            size: ButtonSize.small,
            backgroundColor: TSColor.secondaryGreen.primary,
            contentColor: Colors.black,
            borderColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _showAlternativesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Pengganti untuk ${recommendedFood.food.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              if (recommendedFood.alternatives.isEmpty)
                const Text('Tidak ada alternatif lain.'),
              ...recommendedFood.alternatives.map((altFood) {
                // Sederhanakan kalkulasi kuantitas alternatif
                final newRec = recommendedFood.copyWith(food: altFood);
                return ListTile(
                  title: Text(altFood.name),
                  trailing: TSButton(
                    onPressed: () {
                      onReplace(newRec);
                      Navigator.of(context).pop();
                    },
                    text: 'Pilih',
                    size: ButtonSize.small,
                    backgroundColor: Colors.green,
                    contentColor: Colors.white,
                    borderColor: Colors.transparent,
                  ),
                );
              }),
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
  }
}
