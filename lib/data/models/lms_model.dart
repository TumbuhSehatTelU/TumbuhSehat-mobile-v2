import 'package:equatable/equatable.dart';

class LmsModel extends Equatable {
  final double l;
  final double m;
  final double s;

  const LmsModel({required this.l, required this.m, required this.s});

  factory LmsModel.fromMap(Map<String, dynamic> map) {
    return LmsModel(
      l: (map['L'] as num).toDouble(),
      m: (map['M'] as num).toDouble(),
      s: (map['S'] as num).toDouble(),
    );
  }

  @override
  List<Object> get props => [l, m, s];
}
