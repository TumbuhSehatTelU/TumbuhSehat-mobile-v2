import 'package:equatable/equatable.dart';

class UrtModel extends Equatable {
  final int id;
  final String urtName;
  final double grams;

  const UrtModel({
    required this.id,
    required this.urtName,
    required this.grams,
  });

  factory UrtModel.fromMap(Map<String, dynamic> map) {
    return UrtModel(
      id: map['id'] as int,
      urtName: map['urt_name'] as String,
      grams: (map['grams'] as num).toDouble(),
    );
  }

  @override
  List<Object> get props => [id, urtName, grams];
}