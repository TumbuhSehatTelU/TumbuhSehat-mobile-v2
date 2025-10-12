import 'package:flutter/material.dart';

import '../constants/font_scaling_config.dart';
import 'text_scale_calculator.dart';

class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Get screen width
  double get width => MediaQuery.of(context).size.width;

  /// Get screen height
  double get height => MediaQuery.of(context).size.height;

  /// Check if device is mobile
  bool get isMobile => width < FontScalingConfig.widthBreakpoints['tablet']!;

  /// Check if device is tablet
  bool get isTablet => width >= FontScalingConfig.widthBreakpoints['tablet']!;

  /// Get precise scale factor (integrated with new system)
  double get scaleFactor => TextScaleCalculator.getScaleFactor(context);

  /// Original value method - now supports more granular breakpoints
  T value<T>({
    T? tiny, // < 320dp
    T? small, // 320-360dp
    T? medium, // 360-375dp
    T? standard, // 375-412dp
    T? large, // 412-428dp
    T? xlarge, // 428-600dp
    T? tablet, // 600dp+
  }) {
    if (tablet != null &&
        width >= FontScalingConfig.widthBreakpoints['tablet']!) {
      return tablet;
    }
    if (xlarge != null &&
        width >= FontScalingConfig.widthBreakpoints['xlarge']!) {
      return xlarge;
    }
    if (large != null &&
        width >= FontScalingConfig.widthBreakpoints['large']!) {
      return large;
    }
    if (standard != null &&
        width >= FontScalingConfig.widthBreakpoints['standard']!) {
      return standard;
    }
    if (medium != null &&
        width >= FontScalingConfig.widthBreakpoints['medium']!) {
      return medium;
    }
    if (small != null &&
        width >= FontScalingConfig.widthBreakpoints['small']!) {
      return small;
    }
    if (tiny != null && width >= FontScalingConfig.widthBreakpoints['tiny']!) {
      return tiny;
    }

    // Fallback to standard or first non-null value
    return standard ??
        large ??
        medium ??
        small ??
        xlarge ??
        tablet ??
        tiny ??
        (throw Exception('At least one value must be provided'));
  }

  /// Responsive spacing helper
  double spacing({
    double? tiny,
    double? small,
    double? medium,
    double? standard,
    double? large,
    double? xlarge,
    double? tablet,
  }) {
    return value<double>(
      tiny: tiny,
      small: small,
      medium: medium,
      standard: standard,
      large: large,
      xlarge: xlarge,
      tablet: tablet,
    );
  }

  /// Responsive padding helper
  EdgeInsets padding({
    EdgeInsets? tiny,
    EdgeInsets? small,
    EdgeInsets? medium,
    EdgeInsets? standard,
    EdgeInsets? large,
    EdgeInsets? xlarge,
    EdgeInsets? tablet,
  }) {
    return value<EdgeInsets>(
      tiny: tiny,
      small: small,
      medium: medium,
      standard: standard,
      large: large,
      xlarge: xlarge,
      tablet: tablet,
    );
  }
}
