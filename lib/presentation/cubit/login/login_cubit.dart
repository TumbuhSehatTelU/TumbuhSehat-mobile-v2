// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/family_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'login_state.dart';

const String LOGGED_IN_USER_NAME_KEY = 'LOGGED_IN_USER_NAME';

class LoginCubit extends Cubit<LoginState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;

  LoginCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
  }) : super(LoginInitial());

  Future<void> login({
    required String name,
    required String password,
    required bool rememberMe,
    String? uniqueCode,
    String? phoneNumber,
  }) async {
    emit(LoginLoading());
    final result = await onboardingRepository.login(
      name: name,
      password: password,
      rememberMe: rememberMe,
      uniqueCode: uniqueCode,
      phoneNumber: phoneNumber,
    );

    await result.fold(
      (failure) async => emit(LoginFailure(message: failure.message)),
      (family) async {
        if (rememberMe) {
          await sharedPreferences.setString(LOGGED_IN_USER_NAME_KEY, name);
        } else {
          await sharedPreferences.remove(LOGGED_IN_USER_NAME_KEY);
        }
        emit(LoginSuccess(family: family, loggedInUserName: name));
      },
    );
  }
}
