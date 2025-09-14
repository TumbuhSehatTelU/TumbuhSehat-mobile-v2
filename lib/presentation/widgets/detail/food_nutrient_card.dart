import 'package:flutter/material.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/daily_detail_model.dart';

class FoodNutrientCard extends StatelessWidget {
  final FoodDetail foodDetail;

  const FoodNutrientCard({super.key, required this.foodDetail});

  @override
  Widget build(BuildContext context) {
    // Kelompokkan nutrisi untuk ditampilkan
    final mainNutrients = {
      'Protein': '${foodDetail.protein.toStringAsFixed(1)} g',
      'Lemak': '${foodDetail.fat.toStringAsFixed(1)} g',
      'Karbohidrat': '${foodDetail.carbohydrates.toStringAsFixed(1)} g',
      'Serat': '${foodDetail.fiber.toStringAsFixed(1)} g',
    };
    final vitamins = foodDetail.vitamins;
    final minerals = foodDetail.minerals;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Nama Makanan & Kalori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foodDetail.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${foodDetail.calories.toStringAsFixed(0)} Kkal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TSColor.mainTosca.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Daftar Nutrisi Utama
            ...mainNutrients.entries.map((entry) {
              // Hanya tampilkan jika nilainya lebih dari 0
              if (double.tryParse(entry.value.split(' ')[0])! > 0) {
                return _buildNutrientRow(entry.key, entry.value);
              }
              return const SizedBox.shrink();
            }).toList(),
            // Expander untuk Vitamin & Mineral
            if (vitamins.isNotEmpty || minerals.isNotEmpty)
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Lihat Vitamin & Mineral'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    if (vitamins.isNotEmpty)
                      _buildNutrientSection('Vitamin', vitamins),
                    if (minerals.isNotEmpty)
                      _buildNutrientSection('Mineral', minerals),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: TSColor.monochrome.grey)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildNutrientSection(String title, Map<String, double> nutrients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...nutrients.entries.map((entry) {
          if (entry.value > 0) {
            // Tentukan unit berdasarkan nama nutrisi
            final unit =
                (entry.key.contains('vit_a') || entry.key.contains('carotene'))
                ? 'mcg'
                : 'mg';
            return _buildNutrientRow(
              _formatNutrientName(entry.key),
              '${entry.value.toStringAsFixed(1)} $unit',
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
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
