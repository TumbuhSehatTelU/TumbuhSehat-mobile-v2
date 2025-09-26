import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/weekly_summary_model.dart';
import '../../../gen/assets.gen.dart';

class NutrientSummaryGrid extends StatelessWidget {
  final Map<String, NutrientSummary> summaries;

  const NutrientSummaryGrid({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    final nutrients = [
      {'name': 'Kalori', 'key': 'calories', 'icon': Assets.icons.flame.path},
      {'name': 'Karbo', 'key': 'carbohydrates', 'icon': Assets.icons.rice.path},
      {'name': 'Protein', 'key': 'protein', 'icon': Assets.icons.meat.path},
      {'name': 'Serat', 'key': 'fiber', 'icon': Assets.icons.leaf.path},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.45,
        ),
        itemCount: nutrients.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final nutrient = nutrients[index];
          final summary =
              summaries[nutrient['key']] ??
              const NutrientSummary(totalIntake: 0, target: 1);
          return _NutrientSummaryCard(
            title: nutrient['name']!,
            iconPath: nutrient['icon']!,
            summary: summary,
          );
        },
      ),
    );
  }
}

class _NutrientSummaryCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final NutrientSummary summary;

  const _NutrientSummaryCard({
    required this.title,
    required this.iconPath,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = summary.percentage;

    String statusText;
    Color statusColor;

    if (percentage < 60) {
      statusText = 'Belum Tercukupi';
      statusColor = TSColor.additionalColor.red;
    } else if (percentage < 80) {
      statusText = 'Hampir Tercukupi';
      statusColor = TSColor.additionalColor.yellow;
    } else if (percentage <= 110) {
      statusText = 'Memenuhi Target';
      statusColor = TSColor.additionalColor.green;
    } else {
      statusText = 'Berlebih';
      statusColor = TSColor.additionalColor.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: TSShadow.shadows.weight300,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(iconPath, width: 28, height: 28),

          Text(
            '$title Mingguan',
            style: TSFont.getStyle(
              context,
              TSFont.medium.small.withColor(TSColor.monochrome.black),
            ),
          ),
          const SizedBox(height: 0),

          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TSFont.getStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.black),
            ),
          ),

          Text(
            statusText,
            style: TSFont.getStyle(
              context,
              TSFont.bold.large.withColor(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
