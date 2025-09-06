import 'package:flutter/material.dart';

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
//   style: getResponsiveTextStyle(context, TSFont.regular.h1),
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
}

class Regular {
  Regular();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    letterSpacing: -1.5,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    letterSpacing: -1,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.5,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 1,
  );
}

class Medium {
  Medium();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.5,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -1,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );
}

class SemiBold {
  SemiBold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );
}

class Bold {
  Bold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}

class ExtraBold {
  ExtraBold();
  final TextStyle h0 = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
  );

  final TextStyle h1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  final TextStyle large = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  final TextStyle body = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  final TextStyle small = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );
}
