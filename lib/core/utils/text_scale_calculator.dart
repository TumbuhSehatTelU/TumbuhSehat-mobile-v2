import 'package:flutter/material.dart';
import '../constants/font_scaling_config.dart';

class TextScaleCalculator {
  /// Calculate scale factor based on screen width ratio
  static double calculateRatioScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Calculate ratio from baseline
    double ratio = width / FontScalingConfig.baselineWidth;

    // Apply smoothing curve to prevent extreme scaling
    // Use square root to make scaling less aggressive
    ratio = _smoothScaling(ratio);

    // Clamp to safe range
    return ratio.clamp(
      FontScalingConfig.minScaleFactor,
      FontScalingConfig.maxScaleFactor,
    );
  }

  /// Calculate scale factor based on width zones
  static double calculateZoneScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < FontScalingConfig.widthBreakpoints['small']!) {
      return FontScalingConfig.zoneScaleFactors['tiny']!;
    } else if (width < FontScalingConfig.widthBreakpoints['medium']!) {
      return FontScalingConfig.zoneScaleFactors['small']!;
    } else if (width < FontScalingConfig.widthBreakpoints['standard']!) {
      return FontScalingConfig.zoneScaleFactors['medium']!;
    } else if (width < FontScalingConfig.widthBreakpoints['large']!) {
      return FontScalingConfig.zoneScaleFactors['standard']!;
    } else if (width < FontScalingConfig.widthBreakpoints['xlarge']!) {
      return FontScalingConfig.zoneScaleFactors['large']!;
    } else if (width < FontScalingConfig.widthBreakpoints['tablet']!) {
      return FontScalingConfig.zoneScaleFactors['xlarge']!;
    } else {
      return FontScalingConfig.zoneScaleFactors['tablet']!;
    }
  }

  /// Get final scale factor based on config mode
  static double getScaleFactor(BuildContext context) {
    if (FontScalingConfig.useRatioScaling) {
      return calculateRatioScaleFactor(context);
    } else {
      return calculateZoneScaleFactor(context);
    }
  }

  /// Apply adaptive multiplier based on font size
  static double applyAdaptiveScaling({
    required double baseFontSize,
    required double scaleFactor,
  }) {
    if (!FontScalingConfig.useAdaptiveFontScaling) {
      return scaleFactor;
    }

    // Determine font category
    String category = _getFontCategory(baseFontSize);

    // Get multiplier for this category
    double multiplier = FontScalingConfig.fontSizeMultipliers[category] ?? 1.0;

    // Apply multiplier
    return scaleFactor * multiplier;
  }

  /// Calculate final font size with all scaling applied
  static double calculateFinalFontSize({
    required BuildContext context,
    required double baseFontSize,
  }) {
    // Get base scale factor from screen width
    double scaleFactor = getScaleFactor(context);

    // Apply adaptive scaling based on font size
    double adaptiveScaleFactor = applyAdaptiveScaling(
      baseFontSize: baseFontSize,
      scaleFactor: scaleFactor,
    );

    // Calculate final size
    double finalSize = baseFontSize * adaptiveScaleFactor;

    // Safety clamp (prevent extreme sizes)
    return finalSize.clamp(
      baseFontSize * FontScalingConfig.minScaleFactor,
      baseFontSize * FontScalingConfig.maxScaleFactor,
    );
  }

  /// Smooth scaling curve to prevent jumps
  static double _smoothScaling(double ratio) {
    if (ratio < 1.0) {
      // For smaller screens, use gentle curve
      // sqrt makes scaling less aggressive for small devices
      return 0.7 + (ratio * 0.3); // Minimum 0.7, scales up to 1.0
    } else {
      // For larger screens, scale more conservatively
      return 1.0 + ((ratio - 1.0) * 0.5); // Slower growth
    }
  }

  /// Determine font category from size
  static String _getFontCategory(double fontSize) {
    if (fontSize >= 36) return 'h0';
    if (fontSize >= 28) return 'h1';
    if (fontSize >= 22) return 'h2';
    if (fontSize >= 18) return 'h3';
    if (fontSize >= 16) return 'large';
    if (fontSize >= 14) return 'body';
    return 'small';
  }

  /// Debug helper - print scaling info
  static void debugScaling(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final systemScale = MediaQuery.textScaleFactorOf(context);
    final scaleFactor = getScaleFactor(context);
    final adaptiveScale = applyAdaptiveScaling(
      baseFontSize: baseFontSize,
      scaleFactor: scaleFactor,
    );
    final finalSize = calculateFinalFontSize(
      context: context,
      baseFontSize: baseFontSize,
    );

    debugPrint('====== Font Scaling Debug ======');
    debugPrint(
      'Screen: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)} dp',
    );
    debugPrint('System Text Scale: ${systemScale.toStringAsFixed(2)}');
    debugPrint('Base Font Size: $baseFontSize');
    debugPrint('Scale Factor: ${scaleFactor.toStringAsFixed(3)}');
    debugPrint('Adaptive Scale: ${adaptiveScale.toStringAsFixed(3)}');
    debugPrint('Final Font Size: ${finalSize.toStringAsFixed(2)}');
    debugPrint('===============================');
  }
}
