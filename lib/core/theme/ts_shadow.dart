import 'package:flutter/material.dart';

class TSShadow {
  static Shadows shadows = Shadows();
  static Elevations elevations = Elevations();
}

class Shadows {
  Shadows();
  final List<BoxShadow> weight100 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.08),
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  final List<BoxShadow> weight200 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.08),
      offset: Offset(0, 8),
      blurRadius: 8,
      spreadRadius: -4,
    ),
  ];

  final List<BoxShadow> weight300 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 6),
      blurRadius: 8,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.08),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -6,
    ),
  ];

  final List<BoxShadow> weight400 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.08),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  final List<BoxShadow> weight500 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 6),
      blurRadius: 14,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.10),
      offset: Offset(0, 10),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  final List<BoxShadow> weight600 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 8),
      blurRadius: 18,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 12),
      blurRadius: 42,
      spreadRadius: -4,
    ),
  ];

  final List<BoxShadow> weight700 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 8),
      blurRadius: 22,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 14),
      blurRadius: 64,
      spreadRadius: -4,
    ),
  ];

  final List<BoxShadow> weight800 = const [
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.12),
      offset: Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color.fromRGBO(24, 39, 75, 0.14),
      offset: Offset(0, 18),
      blurRadius: 88,
      spreadRadius: -4,
    ),
  ];
}

class Elevations {
  Elevations();
  final List<BoxShadow> weight100 = const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 1,
    ),
  ];

  final List<BoxShadow> weight200 = const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 2,
    ),
  ];

  final List<BoxShadow> weight300 = const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 3,
    ),
  ];

  final List<BoxShadow> weight400 = const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 2),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: 4,
    ),
  ];

  final List<BoxShadow> weight500 = const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 8),
      blurRadius: 12,
      spreadRadius: 6,
    ),
  ];
}
