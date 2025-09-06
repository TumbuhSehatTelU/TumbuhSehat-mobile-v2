import 'package:flutter/material.dart';

import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_shadow.dart';
import '../../core/theme/ts_text_style.dart';

class TSDropdown<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget Function(T item) itemBuilder;
  final double? borderRadius;

  const TSDropdown({
    super.key,
    required this.label,
    this.hintText,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    required this.itemBuilder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? 12.0);
    return Container(
      decoration: BoxDecoration(
        boxShadow: TSShadow.shadows.weight300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        style: TSFont.regular.body.withColor(TSColor.monochrome.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TSFont.regular.body.withColor(TSColor.monochrome.grey),
          hintStyle: TSFont.regular.body.withColor(
            TSColor.monochrome.lightGrey,
          ),
          filled: true,
          fillColor: TSColor.monochrome.pureWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: effectiveBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: effectiveBorderRadius,
            borderSide: BorderSide(color: TSColor.mainTosca.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: effectiveBorderRadius,
            borderSide: BorderSide(
              color: TSColor.additionalColor.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: effectiveBorderRadius,
            borderSide: BorderSide(
              color: TSColor.additionalColor.red,
              width: 2,
            ),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: TSColor.monochrome.grey),
        isExpanded: true,
      ),
    );
  }
}
