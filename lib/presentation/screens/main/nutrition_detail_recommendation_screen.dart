import 'package:flutter/material.dart';

class NutritionDetailRecommendationScreen extends StatefulWidget {
  final String memberName;

  const NutritionDetailRecommendationScreen({super.key, required this.memberName});

  @override
  State<NutritionDetailRecommendationScreen> createState() => _NutritionDetailRecommendationScreenState();
}

class _NutritionDetailRecommendationScreenState extends State<NutritionDetailRecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Gizi ${widget.memberName}')),
      body: Center(
        child: Text('Ini halaman detail gizi untuk ${widget.memberName}'),
      ),
    );
  }
}
