import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';

class AnalysisCard extends StatelessWidget {
  final String assetPath;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AnalysisCard({
    super.key,
    required this.assetPath,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? TSColor.secondaryGreen.primary
        : TSColor.monochrome.white;
    final textColor = isSelected
        ? TSColor.monochrome.white
        : TSColor.secondaryGreen.shade500;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: TSShadow.shadows.weight600,
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                SvgPicture.asset(assetPath, width: 72, height: 72),
                const SizedBox(width: 24),
                Text(
                  text,
                  style: getResponsiveTextStyle(
                    context,
                    TSFont.bold.h2.withColor(textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
