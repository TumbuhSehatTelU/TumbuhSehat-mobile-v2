import 'package:flutter/material.dart';

class TSColor {
  static MainTosca mainTosca = MainTosca();
  static SecondaryGreen secondaryGreen = SecondaryGreen();
  static Monochrome monochrome = Monochrome();
  static AdditionalColor additionalColor = AdditionalColor();
}

class MainTosca {
  MainTosca();
  final Color shade100 = const Color.fromRGBO(129, 225, 221, 1);
  final Color shade200 = const Color.fromRGBO(83, 205, 200, 1);
  final Color primary = const Color.fromRGBO(22, 179, 172, 1);
  final Color shade400 = const Color.fromRGBO(18, 143, 138, 1);
  final Color shade500 = const Color.fromRGBO(13, 107, 103, 1);
  final Color shade600 = const Color.fromRGBO(11, 89, 86, 1);
}

class SecondaryGreen {
  SecondaryGreen();
  final Color shade100 = const Color.fromRGBO(250, 254, 162, 1);
  final Color shade200 = const Color.fromRGBO(234, 240, 98, 1);
  final Color primary = const Color.fromRGBO(210, 220, 2, 1);
  final Color shade400 = const Color.fromRGBO(173, 182, 2, 1);
  final Color shade500 = const Color.fromRGBO(137, 143, 1, 1);
  final Color shade600 = const Color.fromRGBO(106, 111, 1, 1);
}

class Monochrome {
  Monochrome();
  final Color transparent = const Color.fromRGBO(176, 176, 190, 0.6);
  final Color black = const Color.fromRGBO(19, 19, 26, 1);
  final Color darkGrey = const Color.fromRGBO(73, 74, 80, 1);
  final Color grey = const Color.fromRGBO(104, 104, 104, 1);
  final Color lightGrey = const Color.fromRGBO(178, 178, 178, 1);
  final Color white = const Color.fromRGBO(245, 245, 250, 1);
  final Color pureWhite = const Color.fromRGBO(255, 255, 255, 1);
}

class AdditionalColor {
  AdditionalColor();
  final Color red = const Color.fromRGBO(240, 84, 82, 1);
  final Color orange = const Color.fromRGBO(252, 178, 73, 1);
  final Color yellow = const Color.fromRGBO(243, 246, 119, 1);
  final Color green = const Color.fromRGBO(100, 207, 100, 1);
  final Color blue = const Color.fromRGBO(89, 128, 204, 1);
  final Color purple = const Color.fromRGBO(192, 107, 186, 1);
}
