import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/family_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final OnboardingRepository onboardingRepository;

  LoginCubit({required this.onboardingRepository}) : super(LoginInitial());

  Future<void> login({
    required String name,
    required String password,
    required bool rememberMe,
    String? uniqueCode,
    String?
    phoneNumber,
  }) async {
    emit(LoginLoading());
    final result = await onboardingRepository.login(
      name: name,
      password: password,
      rememberMe: rememberMe,
      uniqueCode: uniqueCode,
    );

    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (family) => emit(LoginSuccess(family: family)),
    );
  }
}
