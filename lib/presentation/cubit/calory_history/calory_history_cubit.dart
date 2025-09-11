import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/weekly_summary_model.dart';
import '../../../domain/repositories/nutrition_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'calory_history_state.dart';

enum CaloryChartRange { oneMonth, threeMonths }

class CaloryHistoryCubit extends Cubit<CaloryHistoryState> {
  final NutritionRepository nutritionRepository;
  final OnboardingRepository onboardingRepository;

  List<dynamic> _allMembersCache = [];

  CaloryHistoryCubit({
    required this.nutritionRepository,
    required this.onboardingRepository,
  }) : super(CaloryHistoryInitial());

  Future<void> loadInitialData(String initialMemberName) async {
    emit(CaloryHistoryLoading());

    final familyResult = await onboardingRepository.getCachedFamily();
    if (familyResult.isLeft()) {
      emit(const CaloryHistoryError('Gagal memuat data keluarga.'));
      return;
    }
    final family = familyResult.getOrElse(() => throw Exception());
    _allMembersCache = [...family.children, ...family.parents];

    final initialMember = _allMembersCache.firstWhere(
      (m) => m.name == initialMemberName,
      orElse: () => _allMembersCache.isNotEmpty ? _allMembersCache.first : null,
    );

    if (initialMember == null) {
      emit(
        const CaloryHistoryError('Tidak ada anggota keluarga yang ditemukan.'),
      );
      return;
    }

    await _fetchAndEmitSummary(initialMember);
  }

  Future<void> changeMember(dynamic newMember) async {
    await _fetchAndEmitSummary(newMember);
  }

  Future<void> changeChartRange(CaloryChartRange range) async {
    if (state is! CaloryHistoryLoaded) return;

    final currentState = state as CaloryHistoryLoaded;
    emit(CaloryHistoryLoading());

    final duration = range == CaloryChartRange.oneMonth
        ? const Duration(days: 30)
        : const Duration(days: 90);

    final summaryResult = await nutritionRepository.getWeeklySummary(
      member: currentState.currentMember,
      endDate: DateTime.now(),
      duration: duration,
    );

    summaryResult.fold((failure) => emit(CaloryHistoryError(failure.message)), (
      summary,
    ) {
      emit(
        CaloryHistoryLoaded(
          summary: summary,
          allMembers: currentState.allMembers,
          currentMember: currentState.currentMember,
        ),
      );
    });
  }

  Future<void> _fetchAndEmitSummary(dynamic member) async {
    final summaryResult = await nutritionRepository.getWeeklySummary(
      member: member,
      endDate: DateTime.now(),
      duration: const Duration(days: 7),
    );

    summaryResult.fold(
      (failure) => emit(CaloryHistoryError(failure.message)),
      (summary) => emit(
        CaloryHistoryLoaded(
          summary: summary,
          allMembers: _allMembersCache,
          currentMember: member,
        ),
      ),
    );
  }
}
