// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionResponseModel _$PredictionResponseModelFromJson(
  Map<String, dynamic> json,
) => PredictionResponseModel(
  components: (json['components'] as List<dynamic>)
      .map((e) => PredictionComponentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PredictionResponseModelToJson(
  PredictionResponseModel instance,
) => <String, dynamic>{
  'components': instance.components.map((e) => e.toJson()).toList(),
};

PredictionComponentModel _$PredictionComponentModelFromJson(
  Map<String, dynamic> json,
) => PredictionComponentModel(
  label: json['label'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  volumeMl: (json['volume_ml'] as num).toDouble(),
  massG: (json['mass_g'] as num).toDouble(),
);

Map<String, dynamic> _$PredictionComponentModelToJson(
  PredictionComponentModel instance,
) => <String, dynamic>{
  'label': instance.label,
  'confidence': instance.confidence,
  'volume_ml': instance.volumeMl,
  'mass_g': instance.massG,
};
