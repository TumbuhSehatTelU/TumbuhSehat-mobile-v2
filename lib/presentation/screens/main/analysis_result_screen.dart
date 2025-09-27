import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/models/prediction_model.dart';

class AnalysisResultScreen extends StatelessWidget {
  final PredictionResponseModel result;

  const AnalysisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Formatter untuk membuat JSON lebih mudah dibaca
    const jsonEncoder = JsonEncoder.withIndent('  ');
    final prettyJson = jsonEncoder.convert(result.toJson());

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis API')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          prettyJson,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
