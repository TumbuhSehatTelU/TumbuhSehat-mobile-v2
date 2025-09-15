// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
        color: TSColor.monochrome.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
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
        selectedColor: Colors.white,
        color: TSColor.monochrome.grey,
        fillColor: TSColor.mainTosca.primary,
        renderBorder: false,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Hari Ini'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Besok'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Lusa'),
          ),
        ],
      ),
    );
  }
}
