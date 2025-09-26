import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  final double _width;

  ResponsiveHelper(this.context) : _width = MediaQuery.of(context).size.width;

  static const double _smallPhoneMaxWidth = 360;
  static const double _standardPhoneMaxWidth = 480;
  static const double _largePhoneMaxWidth = 600;

  bool get isSmallPhone => _width <= _smallPhoneMaxWidth;
  bool get isStandardPhone =>
      _width > _smallPhoneMaxWidth && _width <= _standardPhoneMaxWidth;
  bool get isLargePhone =>
      _width > _standardPhoneMaxWidth && _width <= _largePhoneMaxWidth;
  bool get isTablet => _width > _largePhoneMaxWidth;

  T value<T>({T? small, T? standard, T? large, T? tablet}) {
    if (isTablet) {
      return tablet ?? large ?? standard ?? small!;
    }
    if (isLargePhone) {
      return large ?? standard ?? small!;
    }
    if (isStandardPhone) {
      return standard ?? small!;
    }
    return small ?? standard!;
  }
}
