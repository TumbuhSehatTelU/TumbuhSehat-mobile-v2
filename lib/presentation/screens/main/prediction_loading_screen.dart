import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../injection_container.dart';
import '../../cubit/food_prediction/food_prediction_cubit.dart';
import '../scan/manual_input_screen.dart';

class PredictionLoadingScreen extends StatefulWidget {
  final XFile imageFile;
  final Set<ParentModel> selectedParents;
  final Set<ChildModel> selectedChildren;

  const PredictionLoadingScreen({
    super.key,
    required this.imageFile,
    required this.selectedParents,
    required this.selectedChildren,
  });

  @override
  State<PredictionLoadingScreen> createState() =>
      _PredictionLoadingScreenState();
}

class _PredictionLoadingScreenState extends State<PredictionLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<FoodPredictionCubit>()..predictFood(widget.imageFile),
      child: Scaffold(
        appBar: AppBar(title: const Text('Menganalisis Makanan')),
        body: BlocConsumer<FoodPredictionCubit, FoodPredictionState>(
          listener: (context, state) {
            if (state is FoodPredictionLoaded) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ManualInputScreen(
                    predictionResult: state.result,
                    selectedParents: widget.selectedParents,
                    selectedChildren: widget.selectedChildren,
                  ),
                ),
              );
            } else if (state is FoodPredictionError) {
              print('Prediction Error: ${state.message}');
            }
          },
          builder: (context, state) {
            if (state is FoodPredictionError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal Menganalisis Gambar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Tampilkan loading untuk state Initial dan Loading
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang menganalisis, mohon tunggu...'),
                  Text('(Proses ini bisa memakan waktu hingga 30 detik)'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
