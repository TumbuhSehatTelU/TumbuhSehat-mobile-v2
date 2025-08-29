import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/onboarding_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final OnboardingRepository onboardingRepository;

  SplashCubit({required this.onboardingRepository}) : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    final result = await onboardingRepository.getCachedFamily();

    result.fold(
      (failure) =>
          emit(SplashUnauthenticated()), 
      (family) =>
          emit(SplashAuthenticated()),
    );
  }
}
