import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.title} - ${widget.time}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: TSColor.monochrome.grey,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          ListView.builder(
            itemCount: widget.foods.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return FoodNutrientCard(foodDetail: widget.foods[index]);
            },
          ),
        const Divider(),
      ],
    );
  }
}
