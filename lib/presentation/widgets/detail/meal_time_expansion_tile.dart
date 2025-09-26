import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/daily_detail_model.dart';
import 'food_nutrient_card.dart';

class MealTimeExpansionTile extends StatefulWidget {
  final String title;
  final String time;
  final List<FoodDetail> foods;

  const MealTimeExpansionTile({
    super.key,
    required this.title,
    required this.time,
    required this.foods,
  });

  @override
  State<MealTimeExpansionTile> createState() => _MealTimeExpansionTileState();
}

class _MealTimeExpansionTileState extends State<MealTimeExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.foods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.title} - ${widget.time}',
                  style: TSFont.getStyle(context, TSFont.bold.h3),
                ),
                Icon(
                  _isExpanded
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: TSColor.monochrome.grey,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          ...widget.foods.asMap().entries.map((entry) {
            final index = entry.key;
            final food = entry.value;
            return Container(
              margin: EdgeInsets.only(
                top: 4,
                bottom: index == widget.foods.length - 1 ? 16 : 20,
              ),
              child: FoodNutrientCard(
                foodDetail: food,
                isLastItem: index == widget.foods.length - 1,
              ),
            );
          }),
        ],
        Container(
          height: 2,
          color: TSColor.monochrome.lightGrey,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
      ],
    );
  }
}
