import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prediction_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PredictionResponseModel extends Equatable {
  final List<PredictionComponentModel> components;

  const PredictionResponseModel({required this.components});

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionResponseModelToJson(this);

  @override
  List<Object> get props => [components];
}

@JsonSerializable()
class PredictionComponentModel extends Equatable {
  final String label;
  final double confidence;

  @JsonKey(name: 'volume_ml')
  final double volumeMl;

  @JsonKey(name: 'mass_g')
  final double massG;

  const PredictionComponentModel({
    required this.label,
    required this.confidence,
    required this.volumeMl,
    required this.massG,
  });

  factory PredictionComponentModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionComponentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionComponentModelToJson(this);

  @override
  List<Object> get props => [label, confidence, volumeMl, massG];
}
