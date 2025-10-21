import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../core/theme/ts_color.dart';
import '../../../gen/assets.gen.dart';

class DailyCaloryGauge extends StatelessWidget {
  final double consumedCalories;
  final double targetCalories;

  const DailyCaloryGauge({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final safeTarget = targetCalories > 0 ? targetCalories : 1.0;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: _buildGauge(context, consumedCalories, safeTarget),
          ),

          Positioned(
            left: 24,
            child: _buildInfoColumn(
              context: context,
              svgIconPath: Assets.icons.forkKnife.path,
              value: consumedCalories.toStringAsFixed(0),
              label: 'terpenuhi',
              color: TSColor.secondaryGreen.primary,
              fontColor: TSColor.monochrome.black,
            ),
          ),

          Positioned(
            right: 24,
            child: _buildInfoColumn(
              context: context,
              svgIconPath: Assets.icons.miniFlame.path,
              value: (safeTarget - consumedCalories)
                  .clamp(0, safeTarget)
                  .toStringAsFixed(0),
              label: 'dibutuhkan',
              color: TSColor.additionalColor.orange,
              fontColor: TSColor.additionalColor.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required BuildContext context,
    required String svgIconPath,
    required String value,
    required String label,
    required Color color,
    required Color fontColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgIconPath,
          width: 36,
          height: 36,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(height: 8),
        Text(
          '$value kkal',
          style: TSFont.getStyle(
            context,
            TSFont.extraBold.h3.withColor(fontColor),
          ),
        ),
        Text(label, style: TSFont.getStyle(context, TSFont.medium.body)),
      ],
    );
  }

  Widget _buildGauge(BuildContext context, double consumed, double target) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: (MediaQuery.of(context).size.width * 0.6) / 2 + 10,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: target,
            startAngle: 180,
            endAngle: 0,
            showLabels: false,
            showTicks: false,
            radiusFactor: 1.2,
            axisLineStyle: AxisLineStyle(
              thickness: 0.2,
              cornerStyle: CornerStyle.bothCurve,
              color: TSColor.monochrome.lightGrey,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: consumed,
                width: 0.2,
                sizeUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.bothCurve,
                color: TSColor.secondaryGreen.primary,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0.05,
                angle: 90,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${consumed.toStringAsFixed(0)}/${target.toStringAsFixed(0)}',
                      style: TSFont.getStyle(context, TSFont.bold.h3),
                    ),
                    Text(
                      'kkal',
                      style: TSFont.getStyle(context, TSFont.medium.large),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
