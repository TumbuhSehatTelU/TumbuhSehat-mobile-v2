import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../../domain/repositories/recommendation_repository.dart';

part 'recommendation_state.dart';

enum DaySelection { today, tomorrow, dayAfter }

class RecommendationCubit extends Cubit<RecommendationState> {
  final RecommendationRepository recommendationRepository;
  final OnboardingRepository onboardingRepository;

  List<dynamic> _allMembersCache = [];
  dynamic _currentMember;
  late DateTime _selectedDate;

  RecommendationCubit({
    required this.recommendationRepository,
    required this.onboardingRepository,
  }) : super(RecommendationInitial()) {
    _selectedDate = DateTime.now();
  }

  Future<void> loadInitialData(String initialMemberName) async {
    emit(RecommendationLoading());

    // Muat daftar anggota keluarga terlebih dahulu
    if (_allMembersCache.isEmpty) {
      final familyResult = await onboardingRepository.getCachedFamily();
      if (familyResult.isLeft()) {
        emit(const RecommendationError('Gagal memuat data keluarga.'));
        return;
      }
      final family = familyResult.getOrElse(() => throw Exception());
      _allMembersCache = [...family.children, ...family.parents];
    }

    // Cari objek member yang sebenarnya berdasarkan nama
    _currentMember = _allMembersCache.firstWhere(
      (m) => m.name == initialMemberName,
      orElse: () => _allMembersCache.isNotEmpty ? _allMembersCache.first : null,
    );

    if (_currentMember == null) {
      emit(const RecommendationError('Anggota keluarga tidak ditemukan.'));
      return;
    }

    await _fetchRecommendation();
  }

  Future<void> changeDay(DaySelection day) async {
    final now = DateTime.now();
    switch (day) {
      case DaySelection.today:
        _selectedDate = now;
        break;
      case DaySelection.tomorrow:
        _selectedDate = now.add(const Duration(days: 1));
        break;
      case DaySelection.dayAfter:
        _selectedDate = now.add(const Duration(days: 2));
        break;
    }
    await _fetchRecommendation();
  }

  Future<void> changeMember(dynamic newMember) async {
    if (_currentMember == newMember) return;
    _currentMember = newMember;
    await _fetchRecommendation();
  }

  void replaceFood(MealTime mealTime, int foodIndex, RecommendedFood newFood) {
    if (state is! RecommendationLoaded) return;
    final currentState = state as RecommendationLoaded;

    final newMeals = Map<MealTime, List<RecommendedFood>>.from(
      currentState.recommendation.meals,
    );

    if (newMeals.containsKey(mealTime) &&
        newMeals[mealTime]!.length > foodIndex) {
      newMeals[mealTime]![foodIndex] = newFood;
    }

    final newRecommendation = RecommendationModel(meals: newMeals);

    emit(
      RecommendationLoaded(
        recommendation: newRecommendation,
        displayedDate: currentState.displayedDate,
        currentMember: currentState.currentMember,
        allMembers: currentState.allMembers,
      ),
    );
  }

  Future<void> _fetchRecommendation() async {
    if (_currentMember == null) {
      return;
    }
    if (state is! RecommendationLoaded) {
      emit(RecommendationLoading());
    }

    final result = await recommendationRepository.getMealRecommendation(
      member: _currentMember,
      forDate: _selectedDate,
    );

    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (recommendation) => emit(
        RecommendationLoaded(
          recommendation: recommendation,
          displayedDate: _selectedDate,
          currentMember: _currentMember,
          allMembers: _allMembersCache,
        ),
      ),
    );
  }
}
