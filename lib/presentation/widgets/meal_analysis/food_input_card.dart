import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/urt_model.dart';
import '../../cubit/meal_analysis/meal_analysis_cubit.dart';

class FoodInputCard extends StatelessWidget {
  final FoodCardData cardData;
  final Future<List<FoodModel>> Function(String) onSearch;
  final Function(FoodModel) onFoodSelected;
  final Function(UrtModel?) onUrtSelected;
  final Function(String) onQuantityChanged;
  final VoidCallback onRemove;

  const FoodInputCard({
    super.key,
    required this.cardData,
    required this.onSearch,
    required this.onFoodSelected,
    required this.onUrtSelected,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Controller ini untuk mengelola state text di TypeAheadField
    final TextEditingController typeAheadController = TextEditingController(
      text: cardData.selectedFood?.name ?? '',
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: TSShadow.shadows.weight400,
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: TSColor.monochrome.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  TypeAheadField<FoodModel>(
                    controller: typeAheadController,
                    suggestionsCallback: onSearch,
                    itemBuilder: (context, suggestion) {
                      return ListTile(title: Text(suggestion.name));
                    },
                    onSelected: (food) {
                      typeAheadController.text = food.name;
                      onFoodSelected(food);
                    },
                    emptyBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Makanan tidak ditemukan.'),
                    ),
                    builder: (context, controller, focusNode) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        style: getResponsiveTextStyle(context, TSFont.bold.h2),
                        decoration: InputDecoration(
                          hintText: 'Cari Nama Makanan',
                          hintStyle: getResponsiveTextStyle(
                            context,
                            TSFont.bold.h2.withColor(
                              TSColor.monochrome.lightGrey,
                            ),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 8,
                    thickness: 2,
                    color: TSColor.monochrome.grey,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: cardData.quantityController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            labelStyle: getResponsiveTextStyle(
                              context,
                              TSFont.bold.large,
                            ),
                            border: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: onQuantityChanged,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<UrtModel>(
                          value: cardData.selectedUrt,
                          hint: const Text('Pilih URT'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Ukuran Rumah Tangga (URT)',
                            labelStyle: getResponsiveTextStyle(
                              context,
                              TSFont.bold.large,
                            ),
                            border: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                          ),
                          items: cardData.availableUrts.map((urt) {
                            return DropdownMenuItem(
                              value: urt,
                              child: Text(urt.urtName),
                            );
                          }).toList(),
                          onChanged: onUrtSelected,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Material(
              color: TSColor.additionalColor.red,
              child: InkWell(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: TSColor.monochrome.pureWhite,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: getResponsiveTextStyle(
                          context,
                          TSFont.bold.large.withColor(
                            TSColor.monochrome.pureWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
