import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../domain/repositories/nutrition_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'daily_detail_state.dart';

class DailyDetailCubit extends Cubit<DailyDetailState> {
  final NutritionRepository nutritionRepository;
  final OnboardingRepository onboardingRepository;

  List<dynamic> _allMembersCache = [];
  dynamic _currentMember;
  late DateTime _selectedDate;

  DailyDetailCubit({
    required this.nutritionRepository,
    required this.onboardingRepository,
  }) : super(DailyDetailInitial());

  Future<void> loadInitialData(
    dynamic initialMember,
    DateTime initialDate,
  ) async {
    emit(DailyDetailLoading());

    _currentMember = initialMember;
    _selectedDate = initialDate;

    if (_allMembersCache.isEmpty) {
      final familyResult = await onboardingRepository.getCachedFamily();
      if (familyResult.isLeft()) {
        emit(const DailyDetailError('Gagal memuat data keluarga.'));
        return;
      }
      final family = familyResult.getOrElse(() => throw Exception());
      _allMembersCache = [...family.children, ...family.parents];
    }

    await _fetchData();
  }

  Future<void> changeDate(DateTime newDate) async {
    _selectedDate = newDate;
    await _fetchData();
  }

  Future<void> changeMember(dynamic newMember) async {
    _currentMember = newMember;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (state is! DailyDetailLoaded) {
      emit(DailyDetailLoading());
    }

    final result = await nutritionRepository.getDailyConsumptionDetail(
      member: _currentMember,
      date: _selectedDate,
    );

    result.fold(
      (failure) => emit(DailyDetailError(failure.message)),
      (detail) => emit(
        DailyDetailLoaded(
          detail: detail,
          allMembers: _allMembersCache,
          currentMember: _currentMember,
        ),
      ),
    );
  }
}
