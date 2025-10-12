import 'package:flutter/material.dart';

import '../utils/text_scale_calculator.dart';

// Extension untuk TextStyle
extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }
}

TextStyle getResponsiveTextStyle(BuildContext context, TextStyle mobileStyle) {
  final bool isTablet = MediaQuery.of(context).size.width > 600;
  if (isTablet) {
    return mobileStyle.copyWith(fontSize: mobileStyle.fontSize! * 1.5);
  }
  return mobileStyle;
}

// Penggunaan di widget:
// Text(
//   'ini tulisan',
//   style: TSFont.getStyle(context, TSFont.regular.h1),
// );

// contoh penggunaan
// Text(
//   'ini tulisan',
//   style: Regular.h1.withColor(Main.blue),
// );

class TSFont {
  static Regular regular = Regular();
  static Medium medium = Medium();
  static SemiBold semiBold = SemiBold();
  static Bold bold = Bold();
  static ExtraBold extraBold = ExtraBold();

  /// Get scaled text style based on screen size
  /// This method now uses the new TextScaleCalculator for precise scaling
  static TextStyle getStyle(BuildContext context, TextStyle standardStyle) {
    // Get base font size
    final double baseFontSize = standardStyle.fontSize ?? 14.0;

    // Calculate final scaled font size using new calculator
    final double finalFontSize = TextScaleCalculator.calculateFinalFontSize(
      context: context,
      baseFontSize: baseFontSize,
    );
    return standardStyle.copyWith(fontSize: finalFontSize);
  }
}

class Regular {
  Regular();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.normal,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}

class Medium {
  Medium();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w500,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

class SemiBold {
  SemiBold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

class Bold {
  Bold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
}

class ExtraBold {
  ExtraBold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
}
