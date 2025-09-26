import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../../domain/repositories/recommendation_repository.dart';
import '../login/login_cubit.dart';

part 'beranda_state.dart';

class BerandaCubit extends Cubit<BerandaState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;
  final RecommendationRepository recommendationRepository;

  BerandaCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
    required this.recommendationRepository,
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
    ParentModel currentUser;
    try {
      currentUser = family.parents.firstWhere(
        (p) => p.name == loggedInUserName,
      );
    } catch (e) {
      emit(BerandaError('Data pengguna "$loggedInUserName" tidak cocok.'));
      return;
    }

    // Panggil kedua repository secara paralel
    final results = await Future.wait([
      recommendationRepository.getMealRecommendation(
        member: currentUser,
        forDate: DateTime.now(),
      ),
      recommendationRepository.getMealRecommendation(
        member: currentUser,
        forDate: DateTime.now().add(const Duration(days: 1)),
      ),
    ]);

    final todayResult = results[0];
    final tomorrowResult = results[1];

    // Cek jika salah satu panggilan gagal
    if (todayResult.isLeft() || tomorrowResult.isLeft()) {
      emit(const BerandaError('Gagal memuat data rekomendasi.'));
      return;
    }

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
      ),
    );
  }
}
