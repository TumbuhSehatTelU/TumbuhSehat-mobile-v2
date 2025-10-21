import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/prediction_model.dart';
import '../../../gen/assets.gen.dart';
import '../../screens/main/nutrition_detail_recommendation_screen.dart';
import '../../screens/scan/manual_input_screen.dart';
import '../common/ts_button.dart';

Future<void> showSuccessScanModal(
  BuildContext context, {
  required PredictionResponseModel predictionResult,
  required Set<dynamic> selectedMembers,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(Assets.lottie.smile.path, width: 120, height: 120),
              const SizedBox(height: 16),
              const Text(
                'Makanan Anda telah memenuhi asupan gizi!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TSButton(
                text: 'Lanjutkan',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ManualInputScreen(
                        selectedParents: selectedMembers
                            .whereType<ParentModel>()
                            .toSet(),
                        selectedChildren: selectedMembers
                            .whereType<ChildModel>()
                            .toSet(),
                        predictionResult: predictionResult,
                      ),
                    ),
                  );
                },
                backgroundColor: TSColor.mainTosca.primary,
                borderColor: Colors.transparent,
                contentColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showWarningScanModal(
  BuildContext context, {
  required PredictionResponseModel predictionResult,
  required Set<dynamic> selectedMembers,
  required Set<String> deficientNutrients,
  required List<String> deficientMembers,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset(Assets.lottie.warning.path, width: 120, height: 120),
              const SizedBox(height: 16),
              const Text(
                'Makanan Anda\nbelum memenuhi\nkebutuhan asupan gizi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Kekurangan: ${deficientNutrients.join(', ')}'),
              Text('Untuk: ${deficientMembers.join(', ')}'),
              const SizedBox(height: 24),
              TSButton(
                text: 'Lihat Rekomendasi',
                textStyle: TSFont.getStyle(
                  context,
                  TSFont.bold.large.withColor(TSColor.monochrome.pureWhite),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NutritionDetailRecommendationScreen(
                        initialMemberName: deficientMembers.first,
                      ),
                    ),
                  );
                },
                backgroundColor: TSColor.mainTosca.shade400,
                borderColor: Colors.transparent,
                contentColor: TSColor.monochrome.pureWhite,
                customBorderRadius: 240,
              ),
              const SizedBox(height: 12),
              TSButton(
                text: 'Tetap Lanjutkan',
                textStyle: TSFont.getStyle(
                  context,
                  TSFont.bold.large.withColor(TSColor.additionalColor.orange),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ManualInputScreen(
                        selectedParents: selectedMembers
                            .whereType<ParentModel>()
                            .toSet(),
                        selectedChildren: selectedMembers
                            .whereType<ChildModel>()
                            .toSet(),
                        predictionResult: predictionResult,
                      ),
                    ),
                  );
                },
                backgroundColor: TSColor.monochrome.white,
                borderColor: TSColor.additionalColor.orange,
                borderWidth: 4,
                contentColor: TSColor.additionalColor.orange,
                customBorderRadius: 240,
              ),
            ],
          ),
        ),
      );
    },
  );
}
