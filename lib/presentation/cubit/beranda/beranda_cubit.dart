import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/models/weekly_summary_model.dart';
import '../../../domain/repositories/nutrition_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../../domain/repositories/recommendation_repository.dart';
import '../login/login_cubit.dart';

part 'beranda_state.dart';

class BerandaCubit extends Cubit<BerandaState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;
  final RecommendationRepository recommendationRepository;
  final NutritionRepository nutritionRepository;

  BerandaCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
    required this.recommendationRepository,
    required this.nutritionRepository,
  }) : super(BerandaInitial());

  Future<void> loadBerandaData() async {
    emit(BerandaLoading());

    final loggedInUserName = sharedPreferences.getString(
      LOGGED_IN_USER_NAME_KEY,
    );
    if (loggedInUserName == null || loggedInUserName.isEmpty) {
      emit(const BerandaError('Sesi pengguna tidak ditemukan.'));
      return;
    }

    final familyResult = await onboardingRepository.getCachedFamily();

    if (familyResult.isLeft()) {
      emit(BerandaError(familyResult.fold((l) => l.message, (r) => '')));
      return;
    }

    final family = familyResult.getOrElse(() => throw Exception());

    final allMembers = [...family.children, ...family.parents];
    int initialIndex = allMembers.indexWhere(
      (m) => (m as dynamic).name == loggedInUserName,
    );
    if (initialIndex == -1) initialIndex = 0;

    ParentModel currentUser;
    try {
      currentUser =
          allMembers.firstWhere((m) => (m as dynamic).name == loggedInUserName)
              as ParentModel;
    } catch (e) {
      emit(BerandaError('Data pengguna "$loggedInUserName" tidak cocok.'));
      return;
    }

    final results = await Future.wait([
      recommendationRepository.getMealRecommendation(
        member: currentUser,
        forDate: DateTime.now(),
      ),
      recommendationRepository.getMealRecommendation(
        member: currentUser,
        forDate: DateTime.now().add(const Duration(days: 1)),
      ),
      nutritionRepository.getWeeklySummary(
        member: currentUser,
        targetDate: DateTime.now(),
      ),
    ]);

    final todayResult = results[0] as Either<Failure, RecommendationModel>;
    final tomorrowResult = results[1] as Either<Failure, RecommendationModel>;
    final summaryResult = results[2] as Either<Failure, WeeklySummaryModel>;

    if (todayResult.isLeft() ||
        tomorrowResult.isLeft() ||
        summaryResult.isLeft()) {
      emit(const BerandaError('Gagal memuat data beranda.'));
      return;
    }
    if (todayResult.isRight() &&
        tomorrowResult.isRight() &&
        summaryResult.isRight()) {
      emit(
        BerandaLoaded(
          family: family,
          currentUser: currentUser,
          recommendationForToday: todayResult.getOrElse(
            () => RecommendationModel.empty(),
          ),
          recommendationForTomorrow: tomorrowResult.getOrElse(
            () => RecommendationModel.empty(),
          ),
          weeklySummary: summaryResult.getOrElse(() => throw Exception()),
          initialMemberIndex: initialIndex,
        ),
      );
    } else {
      emit(const BerandaError('Gagal memuat data beranda.'));
    }
  }

  Future<void> changeMember(dynamic newMember) async {
    if (state is! BerandaLoaded) return;
    final currentState = state as BerandaLoaded;

    if (currentState.currentUser.name == newMember.name) return;

    emit(currentState.copyWith(isChangingMember: true, currentUser: newMember));

    final results = await Future.wait([
      recommendationRepository.getMealRecommendation(
        member: newMember,
        forDate: DateTime.now(),
      ),
      recommendationRepository.getMealRecommendation(
        member: newMember,
        forDate: DateTime.now().add(const Duration(days: 1)),
      ),
      nutritionRepository.getWeeklySummary(
        member: newMember,
        targetDate: DateTime.now(),
      ),
    ]);

    final todayResult = results[0] as Either<Failure, RecommendationModel>;
    final tomorrowResult = results[1] as Either<Failure, RecommendationModel>;
    final summaryResult = results[2] as Either<Failure, WeeklySummaryModel>;

    if (todayResult.isLeft() ||
        tomorrowResult.isLeft() ||
        summaryResult.isLeft()) {
      emit(const BerandaError('Gagal memuat data beranda.'));
      return;
    }

    if (todayResult.isRight() &&
        tomorrowResult.isRight() &&
        summaryResult.isRight()) {
      final allMembers = [
        ...currentState.family.children,
        ...currentState.family.parents,
      ];
      final newIndex = allMembers.indexWhere(
        (m) => (m as dynamic).name == newMember.name,
      );

      emit(
        BerandaLoaded(
          family: currentState.family,
          currentUser: newMember,
          recommendationForToday: todayResult.getOrElse(
            () => RecommendationModel.empty(),
          ),
          recommendationForTomorrow: tomorrowResult.getOrElse(
            () => RecommendationModel.empty(),
          ),
          weeklySummary: summaryResult.getOrElse(() => throw Exception()),
          isChangingMember: false,
          initialMemberIndex: newIndex != -1 ? newIndex : 0,
        ),
      );
    } else {
      emit(currentState.copyWith(isChangingMember: false));
    }
  }

  Future<void> refreshBeranda() async {
    if (state is! BerandaLoading) {
      await loadBerandaData();
    }
  }
}
