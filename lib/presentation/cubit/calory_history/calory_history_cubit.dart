import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/weekly_intake_model.dart';
import '../../../data/models/weekly_summary_model.dart';
import '../../../domain/repositories/nutrition_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'calory_history_state.dart';

enum CaloryChartRange { oneMonth, threeMonths }

class CaloryHistoryCubit extends Cubit<CaloryHistoryState> {
  final NutritionRepository nutritionRepository;
  final OnboardingRepository onboardingRepository;
  DateTime? _firstHistoryDate;

  List<dynamic> _allMembersCache = [];
  late DateTime _selectedMonth;
  dynamic _currentMember;

  CaloryHistoryCubit({
    required this.nutritionRepository,
    required this.onboardingRepository,
  }) : super(CaloryHistoryInitial()) {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  Future<void> loadInitialData(String initialMemberName) async {
    emit(CaloryHistoryLoading());

    final familyResult = await onboardingRepository.getCachedFamily();
    if (familyResult.isLeft()) {
      emit(const CaloryHistoryError('Gagal memuat data keluarga.'));
      return;
    }
    final family = familyResult.getOrElse(() => throw Exception());
    _allMembersCache = [...family.children, ...family.parents];

    _currentMember = _allMembersCache.firstWhere(
      (m) => m.name == initialMemberName,
      orElse: () => _allMembersCache.isNotEmpty ? _allMembersCache.first : null,
    );

    if (_currentMember == null) {
      emit(
        const CaloryHistoryError('Tidak ada anggota keluarga yang ditemukan.'),
      );
      return;
    }

    final dateRangeResult = await nutritionRepository.getHistoryDateRange(
      member: _currentMember,
    );
    dateRangeResult.fold((failure) {}, (range) {
      _firstHistoryDate = range.first;
      // _lastHistoryDate = range.last;
    });

    await _fetchAllData();
  }

  Future<void> changeMember(dynamic newMember) async {
    if (_currentMember == newMember) return;
    _currentMember = newMember;
    await _fetchAllData();
  }

  Future<void> changeMonth({required bool isNext}) async {
    final newMonth = DateTime(
      _selectedMonth.year,
      isNext ? _selectedMonth.month + 1 : _selectedMonth.month - 1,
      1,
    );

    if (_firstHistoryDate != null &&
        newMonth.isBefore(
          DateTime(_firstHistoryDate!.year, _firstHistoryDate!.month, 1),
        )) {
      return;
    }

    final now = DateTime.now();
    if (newMonth.isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }

    _selectedMonth = newMonth;
    await _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    if (_currentMember == null) return;

    if (state is! CaloryHistoryLoaded) {
      emit(CaloryHistoryLoading());
    }

    final results = await Future.wait([
      nutritionRepository.getWeeklySummary(
        member: _currentMember,
        endDate: DateTime.now(),
        duration: const Duration(days: 7),
      ),
      nutritionRepository.getMonthlyTrend(
        member: _currentMember,
        month: _selectedMonth,
      ),
    ]);

    final summaryResult = results[0] as Either<Failure, WeeklySummaryModel>;
    final trendResult = results[1] as Either<Failure, List<WeeklyIntake>>;

    if (summaryResult.isLeft() || trendResult.isLeft()) {
      emit(const CaloryHistoryError('Gagal mengambil data riwayat.'));
      return;
    }

    emit(
      CaloryHistoryLoaded(
        summary: summaryResult.getOrElse(() => throw Exception()),
        monthlyTrend: trendResult.getOrElse(() => []),
        allMembers: _allMembersCache,
        currentMember: _currentMember,
        displayedMonth: _selectedMonth,
        firstHistoryDate: _firstHistoryDate,
      ),
    );
  }
}
