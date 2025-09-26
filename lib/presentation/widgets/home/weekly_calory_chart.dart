// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../data/models/akg_model.dart';
import '../../../data/models/weekly_summary_model.dart';

class WeeklyCaloryChart extends StatelessWidget {
  final List<DailyCaloryIntake> dailyIntakes;
  final AkgModel akg;

  const WeeklyCaloryChart({
    super.key,
    required this.dailyIntakes,
    required this.akg,
  });

  @override
  Widget build(BuildContext context) {
    final dailyTarget = akg.calories;
    final maxY = dailyTarget > 0 ? dailyTarget * 1.5 : 2000.0;

    const double leftTitleWidth = 48.0;
    const double bottomTitleHeight = 38.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: TSShadow.shadows.weight400,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: leftTitleWidth,
                    bottom: bottomTitleHeight,
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: _generateBarGroups(dailyTarget),
                      gridData: const FlGridData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: dailyTarget,
                            color: TSColor.mainTosca.primary,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                          ),
                        ],
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),

                _buildManualLeftTitles(
                  maxY,
                  dailyTarget,
                  leftTitleWidth,
                  context,
                ),
                _buildManualBottomTitles(
                  bottomTitleHeight,
                  leftTitleWidth,
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalori Harian (kkal)',
          style: TSFont.getStyle(context, TSFont.semiBold.large),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendItem(TSColor.additionalColor.green, 'Baik', context),
            const SizedBox(width: 8),
            _legendItem(TSColor.additionalColor.yellow, 'Cukup', context),
            const SizedBox(width: 8),
            _legendItem(TSColor.additionalColor.red, 'Kurang', context),
            const SizedBox(width: 8),
            _legendItem(TSColor.additionalColor.orange, 'Berlebih', context),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TSFont.getStyle(
            context,
            TSFont.regular.body.withColor(TSColor.monochrome.black),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups(double dailyTarget) {
    return List.generate(7, (index) {
      // index 0 = Senin, 6 = Minggu
      final dayOfWeek = index + 1;
      final intake = dailyIntakes.firstWhere(
        (d) => d.date.weekday == dayOfWeek,
        orElse: () => DailyCaloryIntake(date: DateTime.now(), totalCalories: 0),
      );
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: intake.totalCalories,
            color: _getBarColor(intake.totalCalories, dailyTarget),
            width: 20,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ],
      );
    });
  }

  Color _getBarColor(double intake, double target) {
    if (target <= 0) {
      return TSColor.monochrome.lightGrey;
    }
    final percentage = intake / target;
    if (percentage < 0.6) {
      return TSColor.additionalColor.red;
    }
    if (percentage < 0.8) {
      return TSColor.additionalColor.yellow;
    }
    if (percentage <= 1.1) {
      return TSColor.additionalColor.green;
    }
    return TSColor.additionalColor.orange;
  }

  Widget _buildManualLeftTitles(
    double maxY,
    double dailyTarget,
    double width,
    BuildContext context,
  ) {
    return SizedBox(
      width: width,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              '${(maxY / 1000).toStringAsFixed(0)}k',
              style: TSFont.getStyle(context, TSFont.semiBold.body),
            ),
          ),
          Positioned(
            bottom: (dailyTarget / maxY) * 190,
            left: 0,
            child: Text(
              'Target\n${dailyTarget.toStringAsFixed(0)}',
              style: TSFont.getStyle(
                context,
                TSFont.bold.body.withColor(TSColor.mainTosca.shade400),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualBottomTitles(
    double height,
    double leftPadding,
    BuildContext context,
  ) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final chartAreaWidth =
        MediaQuery.of(context).size.width - (26 * 2) - (16 * 2) - leftPadding;
    final barWidth = chartAreaWidth / 7;
    return Positioned(
      bottom: 0,
      left: leftPadding,
      right: 0,
      height: height,
      child: Stack(
        children: List.generate(7, (index) {
          final isToday = (DateTime.now().weekday - 1) == index;
          return Positioned(
            left: index * barWidth,
            width: barWidth,
            top: 8,
            child: Text(
              days[index],
              textAlign: TextAlign.center,
              style: TSFont.getStyle(
                context,
                TSFont.bold.body.withColor(
                  isToday
                      ? TSColor.mainTosca.primary
                      : TSColor.monochrome.lightGrey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
