// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/weekly_summary_model.dart';
import '../../screens/main/daily_consumption_detail_screen.dart';
import '../common/ts_button.dart';

enum MealTime { Sarapan, MakanSiang, CamilanSore, MakanMalam, CamilanMalam }

class DailyConsumptionList extends StatefulWidget {
  final Map<DateTime, List<MealEntry>> dailyEntries;
  final dynamic currentMember;

  const DailyConsumptionList({
    super.key,
    required this.dailyEntries,
    required this.currentMember,
  });

  @override
  State<DailyConsumptionList> createState() => _DailyConsumptionListState();
}

class _DailyConsumptionListState extends State<DailyConsumptionList> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Map<MealTime, List<MealEntry>> _groupEntriesByMealTime(
    List<MealEntry> entries,
  ) {
    final Map<MealTime, List<MealEntry>> grouped = {};
    for (final entry in entries) {
      final mealTime = _getMealTimeFromDate(entry.time);
      grouped.putIfAbsent(mealTime, () => []).add(entry);
    }
    return grouped;
  }

  MealTime _getMealTimeFromDate(DateTime time) {
    if (time.hour >= 4 && time.hour < 11) return MealTime.Sarapan;
    if (time.hour >= 11 && time.hour < 15) return MealTime.MakanSiang;
    if (time.hour >= 15 && time.hour < 18) return MealTime.CamilanSore;
    if (time.hour >= 18 && time.hour < 22) return MealTime.MakanMalam;
    return MealTime.CamilanMalam;
  }

  @override
  Widget build(BuildContext context) {
    final entriesForSelectedDate = widget.dailyEntries[_selectedDate] ?? [];
    final groupedEntries = _groupEntriesByMealTime(entriesForSelectedDate);
    final sortedMealTimes = List<MealTime>.from(MealTime.values)
      ..sort((a, b) => a.index.compareTo(b.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Konsumsi Gizi Harian',
          style: getResponsiveTextStyle(
            context,
            TSFont.bold.h2.withColor(TSColor.monochrome.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih Tanggal untuk Melihat Konsumsi Gizi',
          style: getResponsiveTextStyle(
            context,
            TSFont.regular.large.withColor(TSColor.monochrome.black),
          ),
        ),
        const SizedBox(height: 16),
        TSButton(
          onPressed: () => _selectDate(context),
          text: DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
          icon: Icons.calendar_month_rounded,
          style: ButtonStyleType.rightIcon,
          textStyle: getResponsiveTextStyle(
            context,
            TSFont.bold.large.withColor(TSColor.monochrome.black),
          ),
          backgroundColor: TSColor.secondaryGreen.shade200,
          borderColor: Colors.transparent,
          customBorderRadius: 240,
          boxShadow: TSShadow.shadows.weight300,
          contentColor: TSColor.monochrome.black,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
        TSButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DailyConsumptionDetailScreen(
                  member: widget.currentMember,
                  date: _selectedDate,
                ),
              ),
            );
          },
          text: 'Lihat Detail',
          textStyle: getResponsiveTextStyle(
            context,
            TSFont.bold.large.withColor(TSColor.monochrome.pureWhite),
          ),
          backgroundColor: TSColor.mainTosca.shade500,
          borderColor: Colors.transparent,
          contentColor: TSColor.monochrome.pureWhite,
          width: double.infinity,
          boxShadow: TSShadow.shadows.weight300,
          customBorderRadius: 240,
          style: ButtonStyleType.leftIcon,
          icon: Icons.info_outline,
        ),
        const SizedBox(height: 24),

        if (entriesForSelectedDate.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 48, bottom: 120),
              child: Text(
                'Tidak ada riwayat makan\npada tanggal ini.',
                style: getResponsiveTextStyle(
                  context,
                  TSFont.medium.h3.withColor(TSColor.mainTosca.shade500),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          Column(
            children: sortedMealTimes.map((mealTime) {
              if (groupedEntries.containsKey(mealTime)) {
                return _MealEntryCard(
                  mealEntries: groupedEntries[mealTime]!,
                  currentMember: widget.currentMember,
                  selectedDate: _selectedDate,
                );
              } else {
                return const SizedBox.shrink();
              }
            }).toList(),
          ),
          const SizedBox(height: 120),
        ],
      ],
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  final List<MealEntry> mealEntries;
  final dynamic currentMember;
  final DateTime selectedDate;

  const _MealEntryCard({
    required this.mealEntries,
    required this.currentMember,
    required this.selectedDate,
  });

  String _getMealTitle(DateTime time) {
    if (time.hour >= 4 && time.hour < 11) return 'Sarapan';
    if (time.hour >= 11 && time.hour < 15) return 'Makan Siang';
    if (time.hour >= 15 && time.hour < 18) return 'Camilan Sore';
    if (time.hour >= 18 && time.hour < 22) return 'Makan Malam';
    return 'Camilan Malam';
  }

  @override
  Widget build(BuildContext context) {
    if (mealEntries.isEmpty) return const SizedBox.shrink();

    final firstEntry = mealEntries.first;
    final title = _getMealTitle(firstEntry.time);
    final timeFormatted = DateFormat('HH:mm').format(firstEntry.time);

    final allComponents = mealEntries.expand((e) => e.components).toList();
    final totalCalories = allComponents.fold<double>(
      0,
      (sum, comp) => sum + comp.calories,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        boxShadow: TSShadow.shadows.weight400,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title - $timeFormatted',
                        style: getResponsiveTextStyle(
                          context,
                          TSFont.bold.h3.withColor(TSColor.monochrome.black),
                        ),
                      ),
                    ),
                    Text(
                      '${totalCalories.toStringAsFixed(0)} Kkal',
                      style: getResponsiveTextStyle(
                        context,
                        TSFont.bold.h3.withColor(TSColor.mainTosca.shade400),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24,
                  thickness: 2,
                  color: TSColor.monochrome.grey,
                  radius: BorderRadius.circular(2),
                ),
                ...allComponents.map((component) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${component.foodName} - ${component.quantity.toStringAsFixed(0)} ${component.urtName}',
                          style: getResponsiveTextStyle(
                            context,
                            TSFont.regular.body.withColor(
                              TSColor.monochrome.black,
                            ),
                          ),
                        ),
                        Text(
                          '${component.calories.toStringAsFixed(0)} Kkal',
                          style: getResponsiveTextStyle(
                            context,
                            TSFont.bold.body.withColor(
                              TSColor.secondaryGreen.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
