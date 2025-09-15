import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/daily_detail_model.dart';

class FoodNutrientCard extends StatelessWidget {
  final FoodDetail foodDetail;
  final bool isLastItem;

  const FoodNutrientCard({
    super.key,
    required this.foodDetail,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainNutrients = {
      '🍖 Protein': '${foodDetail.protein.toStringAsFixed(1)} g',
      '🧈 Lemak': '${foodDetail.fat.toStringAsFixed(1)} g',
      '🍚 Karbohidrat': '${foodDetail.carbohydrates.toStringAsFixed(1)} g',
      '🥬 Serat': '${foodDetail.fiber.toStringAsFixed(1)} g',
    };
    final vitamins = foodDetail.vitamins;
    final minerals = foodDetail.minerals;

    // margin: EdgeInsets.only(bottom: isLastItem ? 8 : 12),
    //       elevation: 2,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

    return Container(
      margin: EdgeInsets.only(bottom: isLastItem ? 8 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TSColor.monochrome.white,
        boxShadow: TSShadow.shadows.weight500,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${foodDetail.foodName} - ${foodDetail.quantity.toStringAsFixed(0)} ${foodDetail.urtName}',
                    style: getResponsiveTextStyle(
                      context,
                      TSFont.semiBold.large.withColor(TSColor.monochrome.black),
                    ),
                  ),
                ),
                Text(
                  '${foodDetail.calories.toStringAsFixed(0)} Kkal',
                  style: getResponsiveTextStyle(
                    context,
                    TSFont.bold.large.withColor(TSColor.mainTosca.shade400),
                  ),
                ),
              ],
            ),
            Divider(
              height: 24,
              thickness: 2,
              color: TSColor.monochrome.lightGrey,
            ),
            ...mainNutrients.entries.map((entry) {
              if (double.tryParse(entry.value.split(' ')[0])! > 0) {
                return _buildNutrientRow(entry.key, entry.value, context);
              }
              return const SizedBox.shrink();
            }),
            if (vitamins.isNotEmpty)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    'Lihat Detail Vitamin',
                    style: getResponsiveTextStyle(
                      context,
                      TSFont.medium.large.withColor(TSColor.monochrome.black),
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    _buildNutrientSection('Vitamin', vitamins, context),
                  ],
                ),
              ),

            if (minerals.isNotEmpty)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    'Lihat Detail Mineral',
                    style: getResponsiveTextStyle(
                      context,
                      TSFont.medium.large.withColor(TSColor.monochrome.black),
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    _buildNutrientSection('Mineral', minerals, context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: getResponsiveTextStyle(
              context,
              TSFont.regular.body.withColor(TSColor.monochrome.black),
            ),
          ),
          Text(
            value,
            style: getResponsiveTextStyle(
              context,
              TSFont.bold.body.withColor(TSColor.secondaryGreen.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientSection(
    String title,
    Map<String, double> nutrients,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...nutrients.entries.map((entry) {
          if (entry.value > 0) {
            final unit =
                (entry.key.contains('vit_a') || entry.key.contains('carotene'))
                ? 'mcg'
                : 'mg';
            return _buildNutrientRow(
              _formatNutrientName(entry.key),
              '${entry.value.toStringAsFixed(1)} $unit',
              context,
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 4),
      ],
    );
  }

  String _formatNutrientName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
