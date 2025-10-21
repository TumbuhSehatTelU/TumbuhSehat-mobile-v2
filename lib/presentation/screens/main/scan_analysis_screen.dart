import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/prediction_model.dart';
import '../../../injection_container.dart';
import '../../cubit/scan_analysis/scan_analysis_cubit.dart';
import '../../widgets/dialogs_and_modals/scan_result_modals.dart';

class ScanAnalysisScreen extends StatelessWidget {
  final PredictionResponseModel predictionResult;
  final Set<dynamic> selectedMembers;

  const ScanAnalysisScreen({
    super.key,
    required this.predictionResult,
    required this.selectedMembers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ScanAnalysisCubit>()
        ..analyzeScannedFood(
          prediction: predictionResult,
          selectedMembers: selectedMembers,
        ),
      child: Scaffold(
        body: BlocListener<ScanAnalysisCubit, ScanAnalysisState>(
          listener: (context, state) {
            if (state is ScanAnalysisSuccess) {
              showSuccessScanModal(
                context,
                predictionResult: predictionResult,
                selectedMembers: selectedMembers,
              );
            } else if (state is ScanAnalysisWarning) {
              showWarningScanModal(
                context,
                predictionResult: predictionResult,
                selectedMembers: selectedMembers,
                deficientNutrients: state.deficientNutrients,
                deficientMembers: state.deficientMembers,
              );
            } else if (state is ScanAnalysisError) {
              Navigator.of(context).pop(); 
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menganalisis kecukupan gizi...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
