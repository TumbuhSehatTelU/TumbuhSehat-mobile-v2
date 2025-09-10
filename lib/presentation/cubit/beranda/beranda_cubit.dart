import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../login/login_cubit.dart';

part 'beranda_state.dart';

class BerandaCubit extends Cubit<BerandaState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;

  BerandaCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
  }) : super(BerandaInitial());

  Future<void> loadBerandaData() async {
    emit(BerandaLoading());

    final familyResult = await onboardingRepository.getCachedFamily();
    final loggedInUserName = sharedPreferences.getString(
      LOGGED_IN_USER_NAME_KEY,
    );

    if (loggedInUserName == null || loggedInUserName.isEmpty) {
      emit(
        const BerandaError(
          'Sesi pengguna tidak ditemukan. Silakan login kembali.',
        ),
      );
      return;
    }

    familyResult.fold((failure) => emit(BerandaError(failure.message)), (
      family,
    ) {
      try {
        final currentUser = family.parents.firstWhere(
          (parent) => parent.name == loggedInUserName,
        );
        emit(BerandaLoaded(family: family, currentUser: currentUser));
      } catch (e) {
        emit(
          BerandaError(
            'Data pengguna "$loggedInUserName" tidak cocok dengan data keluarga.',
          ),
        );
      }
    });
  }
}
