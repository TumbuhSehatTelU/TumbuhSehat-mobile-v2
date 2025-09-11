import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/weekly_summary_model.dart';
import '../../../domain/repositories/nutrition_repository.dart';

part 'calory_history_state.dart';

class CaloryHistoryCubit extends Cubit<CaloryHistoryState> {
  final NutritionRepository nutritionRepository;

  CaloryHistoryCubit({required this.nutritionRepository})
    : super(CaloryHistoryInitial());

  Future<void> fetchWeeklySummary({
    required dynamic member,
    required DateTime date,
  }) async {
    emit(CaloryHistoryLoading());
    final result = await nutritionRepository.getWeeklySummary(
      member: member,
      targetDate: date,
    );
    result.fold(
      (failure) => emit(CaloryHistoryError(failure.message)),
      (summary) => emit(CaloryHistoryLoaded(summary)),
    );
  }
}
