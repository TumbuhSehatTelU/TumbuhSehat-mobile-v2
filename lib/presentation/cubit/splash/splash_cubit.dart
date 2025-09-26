// ignore_for_file: avoid_print

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/family_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../login/login_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;

  SplashCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
  }) : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    await _cleanExpiredRecommendationCache();
    final result = await onboardingRepository.getCachedFamily();

    result.fold((failure) => emit(SplashUnauthenticated()), (family) {
      final loggedInUserName = sharedPreferences.getString(
        LOGGED_IN_USER_NAME_KEY,
      );
      if (loggedInUserName != null && loggedInUserName.isNotEmpty) {
        emit(
          SplashAuthenticated(
            family: family,
            loggedInUserName: loggedInUserName,
          ),
        );
      } else {
        emit(SplashUnauthenticated());
      }
    });
  }

  Future<void> _cleanExpiredRecommendationCache() async {
    final allKeys = sharedPreferences.getKeys();
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final key in allKeys) {
      if (key.startsWith('recommendation_overrides_')) {
        try {
          final dateString = key.split('_').last;
          final keyDate = dateFormat.parse(dateString);

          if (keyDate.isBefore(todayDateOnly)) {
            await sharedPreferences.remove(key);
          }
        } catch (e) {
          print('[CACHE_CLEAN] Gagal mem-parsing key: $key, error: $e');
        }
      }
    }
  }
}
