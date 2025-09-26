// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_color.dart';
import '../../cubit/recommendation/recommendation_cubit.dart';

class DaySelector extends StatefulWidget {
  final Function(DaySelection) onDaySelected;

  const DaySelector({super.key, required this.onDaySelected});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  final List<bool> _isSelected = [true, false, false];
  final List<DaySelection> _days = [
    DaySelection.today,
    DaySelection.tomorrow,
    DaySelection.dayAfter,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TSColor.monochrome.lightGrey.withOpacity(0.32),
        borderRadius: BorderRadius.circular(48),
        border: BoxBorder.all(color: TSColor.mainTosca.shade100, width: 4),
      ),
      child: ToggleButtons(
        isSelected: _isSelected,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < _isSelected.length; i++) {
              _isSelected[i] = i == index;
            }
          });
          widget.onDaySelected(_days[index]);
        },
        borderRadius: BorderRadius.circular(24),
        selectedColor: TSColor.monochrome.black,
        color: TSColor.monochrome.grey,
        fillColor: TSColor.mainTosca.shade100,
        renderBorder: false,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Hari Ini',
              style: getResponsiveTextStyle(context, TSFont.bold.large),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Besok',
              style: getResponsiveTextStyle(context, TSFont.bold.large),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Lusa',
              style: getResponsiveTextStyle(context, TSFont.bold.large),
            ),
          ),
        ],
      ),
    );
  }
}
