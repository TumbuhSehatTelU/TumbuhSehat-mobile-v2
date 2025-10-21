import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/prediction_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../domain/repositories/food_repository.dart';
import '../../../domain/repositories/nutrition_repository.dart';

part 'scan_analysis_state.dart';

class ScanAnalysisCubit extends Cubit<ScanAnalysisState> {
  final NutritionRepository nutritionRepository;
  final FoodRepository foodRepository;

  ScanAnalysisCubit({
    required this.nutritionRepository,
    required this.foodRepository,
  }) : super(ScanAnalysisInitial());

  Future<void> analyzeScannedFood({
    required PredictionResponseModel prediction,
    required Set<dynamic> selectedMembers,
  }) async {
    print("\n--- [DEBUG_ANALYSIS] Memulai Analisis Kecukupan Gizi ---");
    emit(ScanAnalysisLoading());
    try {
      final currentMealTime = getNextRelevantMealTime(null);
      if (currentMealTime == null) {
        print("[DEBUG_ANALYSIS] Di luar jam makan relevan. Langsung sukses.");
        emit(ScanAnalysisSuccess());
        return;
      }
      print("[DEBUG_ANALYSIS] Waktu Makan Saat Ini: ${currentMealTime.name}");

      final scannedNutrients = await _calculateScannedNutrients(prediction);
      print(
        "[DEBUG_ANALYSIS] Total Nutrisi dari Scan: Kalori=${scannedNutrients['calories']?.toStringAsFixed(0)}",
      );

      final Set<String> deficientNutrients = {};
      final List<String> deficientMembers = [];

      print(
        "[DEBUG_ANALYSIS] Memulai loop untuk ${selectedMembers.length} anggota keluarga.",
      );
      for (final member in selectedMembers) {
        print("[DEBUG_ANALYSIS] Menganalisis untuk: ${member.name}");
        final akg = await nutritionRepository.getAkgForMember(member);
        if (akg == null) {
          print(
            "[DEBUG_ANALYSIS] -> GAGAL: AKG tidak ditemukan untuk ${member.name}.",
          );
          continue; // Lanjut ke member berikutnya
        }
        print(
          "[DEBUG_ANALYSIS] -> AKG Harian Ditemukan: ${akg.calories.toStringAsFixed(0)} kkal",
        );

        final mealTarget = _getMealTarget(akg, currentMealTime);
        print(
          "[DEBUG_ANALYSIS] -> Target Nutrisi untuk ${currentMealTime.name}: Kalori=${mealTarget['calories']?.toStringAsFixed(0)}",
        );

        bool isDeficient = false;

        // Cek Kalori
        if (scannedNutrients['calories']! < mealTarget['calories']! * 0.75) {
          deficientNutrients.add('Kalori');
          isDeficient = true;
          print(
            "[DEBUG_ANALYSIS] -> KEKURANGAN: Kalori (${scannedNutrients['calories']!.toStringAsFixed(0)} < ${(mealTarget['calories']! * 0.75).toStringAsFixed(0)})",
          );
        }
        // Cek Protein
        if (scannedNutrients['protein']! < mealTarget['protein']! * 0.75) {
          deficientNutrients.add('Protein');
          isDeficient = true;
          print(
            "[DEBUG_ANALYSIS] -> KEKURANGAN: Protein (${scannedNutrients['protein']!.toStringAsFixed(0)} < ${(mealTarget['protein']! * 0.75).toStringAsFixed(0)})",
          );
        }
        // Cek Karbohidrat
        if (scannedNutrients['carbohydrates']! <
            mealTarget['carbohydrates']! * 0.75) {
          deficientNutrients.add('Karbohidrat');
          isDeficient = true;
          print(
            "[DEBUG_ANALYSIS] -> KEKURANGAN: Karbohidrat (${scannedNutrients['carbohydrates']!.toStringAsFixed(0)} < ${(mealTarget['carbohydrates']! * 0.75).toStringAsFixed(0)})",
          );
        }

        if (isDeficient) {
          deficientMembers.add(member.name);
          print("[DEBUG_ANALYSIS] -> HASIL: ${member.name} kekurangan gizi.");
        } else {
          print("[DEBUG_ANALYSIS] -> HASIL: ${member.name} gizinya cukup.");
        }
      }

      print("[DEBUG_ANALYSIS] Loop selesai.");
      if (deficientMembers.isEmpty) {
        print(
          "[DEBUG_ANALYSIS] KESIMPULAN: Semua anggota tercukupi. Emit Success.",
        );
        emit(ScanAnalysisSuccess());
      } else {
        print(
          "[DEBUG_ANALGLISH] KESIMPULAN: Ada anggota yang kurang gizi. Emit Warning.",
        );
        emit(
          ScanAnalysisWarning(
            deficientNutrients: deficientNutrients,
            deficientMembers: deficientMembers.toSet().toList(),
          ),
        );
      }
      print("--- [DEBUG_ANALYSIS] Analisis Selesai ---");
    } catch (e, stacktrace) {
      print("[DEBUG_ANALYSIS] Exception terjadi: $e");
      print(stacktrace);
      emit(ScanAnalysisError(e.toString()));
    }
  }

  Future<Map<String, double>> _calculateScannedNutrients(
    PredictionResponseModel prediction,
  ) async {
    final totalNutrients = <String, double>{
      'calories': 0,
      'protein': 0,
      'fat': 0,
      'carbohydrates': 0,
      'fiber': 0,
      'water': 0,
    };
    for (final component in prediction.components) {
      if (component.confidence < 0.5) continue;
      final foodResult = await foodRepository.findFoodByAlias(component.label);
      await foodResult.fold((l) => null, (food) {
        if (food != null) {
          final factor = component.massG / 100.0;
          food.nutrients.forEach((key, value) {
            if (value is num) {
              totalNutrients.update(
                key,
                (v) => v + (value.toDouble() * factor),
                ifAbsent: () => value.toDouble() * factor,
              );
            }
          });
        }
      });
    }
    return totalNutrients;
  }

  Map<String, double> _getMealTarget(akg, MealTime mealTime) {
    double percentage = 0.35; // Default (Makan Malam)
    if (mealTime == MealTime.Sarapan) percentage = 0.25;
    if (mealTime == MealTime.MakanSiang) percentage = 0.40;

    return {
      'calories': akg.calories * percentage,
      'protein': akg.protein * percentage,
      'carbohydrates': akg.carbohydrates * percentage,
    };
  }
}

MealTime? getNextRelevantMealTime(RecommendationModel? recommendation) {
  final hour = DateTime.now().hour;
  if (hour >= 4 && hour < 11) {
    return MealTime.Sarapan;
  }
  if (hour >= 11 && hour < 15) {
    return MealTime.MakanSiang;
  }
  if (hour >= 18 && hour < 22) {
    return MealTime.MakanMalam;
  }
  if (hour >= 15 && hour < 18) {
    return MealTime.CamilanSore;
  }
  return MealTime.CamilanMalam;
}
