// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/akg_model.dart';
import '../../../data/models/weekly_intake_model.dart';

class CaloryTrendChart extends StatelessWidget {
  final List<WeeklyIntake> weeklyIntakes;
  final AkgModel akg;
  final DateTime displayedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final DateTime? firstHistoryDate;

  const CaloryTrendChart({
    super.key,
    required this.weeklyIntakes,
    required this.akg,
    required this.displayedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.firstHistoryDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isNextMonthDisabled =
        displayedMonth.year == now.year && displayedMonth.month == now.month;
    bool isPreviousMonthDisabled = false;
    if (firstHistoryDate != null) {
      final firstHistoryMonth = DateTime(
        firstHistoryDate!.year,
        firstHistoryDate!.month,
        1,
      );
      if (!displayedMonth.isAfter(firstHistoryMonth)) {
        isPreviousMonthDisabled = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 24, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isNextMonthDisabled, isPreviousMonthDisabled, context),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              _buildBarChartData(context),
              swapAnimationDuration: const Duration(milliseconds: 250),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeader(
    bool isNextMonthDisabled,
    bool isPreviousMonthDisabled,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: !isPreviousMonthDisabled,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onPreviousMonth,
            ),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(displayedMonth),
            style: getResponsiveTextStyle(
              context,
              TSFont.bold.large.withColor(TSColor.monochrome.black),
            ),
          ),
          Visibility(
            visible: !isNextMonthDisabled,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: onNextMonth,
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(BuildContext context) {
    final weeklyTarget = akg.calories * 7;

    final suggestedMaxY = weeklyTarget > 0 ? weeklyTarget * 1.2 : 5000.0;
    final interval = suggestedMaxY > 10000 ? 5000.0 : 2500.0;

    final calculatedMaxY = (suggestedMaxY / interval).ceil() * interval;
    final visualPadding = interval * 0.2;

    final maxY = calculatedMaxY + visualPadding;
    final minY = -visualPadding;

    return BarChartData(
      maxY: maxY,
      minY: minY,
      barGroups: _generateBarGroups(weeklyTarget),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _getBottomTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval: interval,
            getTitlesWidget: _getLeftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          if (value > calculatedMaxY) return const FlLine(strokeWidth: 0);

          if (value == 0) {
            return FlLine(color: TSColor.monochrome.darkGrey, strokeWidth: 1);
          }
          return FlLine(
            color: TSColor.monochrome.lightGrey,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 8,
          getTooltipColor: (group) => TSColor.monochrome.darkGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.round()} kkal',
              getResponsiveTextStyle(
                context,
                TSFont.bold.large.withColor(TSColor.monochrome.pureWhite),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(double weeklyTarget) {
    return List.generate(5, (index) {
      final weekData = weeklyIntakes.firstWhere(
        (intake) => intake.weekNumber == index + 1,
        orElse: () => WeeklyIntake(weekNumber: index + 1, totalCalories: 0),
      );

      final barColor = _getBarColor(weekData.totalCalories, weeklyTarget);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weekData.totalCalories,
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Color _getBarColor(double intake, double target) {
    if (target <= 0) {
      return TSColor.monochrome.grey;
    }

    final percentage = intake / target;

    if (percentage < 0.6) {
      return TSColor.additionalColor.red;
    } else if (percentage < 0.8) {
      return TSColor.additionalColor.yellow;
    } else if (percentage <= 1.1) {
      return TSColor.additionalColor.green;
    } else {
      return TSColor.additionalColor.orange;
    }
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final text = 'ke-${value.toInt() + 1}';
    return SideTitleWidget(
      space: 16.0,
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: TSFont.bold.body.withColor(TSColor.monochrome.darkGrey),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    var style = TSFont.bold.small.withColor(TSColor.monochrome.darkGrey);

    if (value == meta.max) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 1.0,
        child: Padding(
          padding: EdgeInsets.only(bottom: 36.0),
          child: Text('kkal', style: style),
        ),
      );
    }

    if (value == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 1.0,
        child: Padding(
          padding: EdgeInsets.only(top: 72.0),
          child: Text('Pekan', style: style),
        ),
      );
    }

    if (value % meta.appliedInterval != 0) {
      return Container();
    }

    final text = '${(value / 1000).toStringAsFixed(0)}rb';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 1.0,
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(TSColor.additionalColor.green, 'Cukup', context),
            const SizedBox(height: 4),
            _legendItem(
              TSColor.additionalColor.yellow,
              'Hampir Cukup',
              context,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(TSColor.additionalColor.orange, 'Berlebih', context),
            const SizedBox(height: 4),
            _legendItem(TSColor.additionalColor.red, 'Kurang', context),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: BoxBorder.all(
              width: 1,
              color: TSColor.monochrome.grey.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: getResponsiveTextStyle(
            context,
            TSFont.regular.body.withColor(TSColor.monochrome.black),
          ),
        ),
      ],
    );
  }
}
