
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../../core/database/database_helper.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../login/login_cubit.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;

  ProfileCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
  }) : super(ProfileInitial());

  Future<void> loadProfileData() async {
    emit(const ProfileLoading());
    final loggedInUserName = sharedPreferences.getString(
      LOGGED_IN_USER_NAME_KEY,
    );
    if (loggedInUserName == null) {
      emit(const ProfileError('Sesi tidak ditemukan.'));
      return;
    }

    final familyResult = await onboardingRepository.getCachedFamily();
    familyResult.fold((failure) => emit(ProfileError(failure.message)), (
      family,
    ) {
      try {
        final currentUser = family.parents.firstWhere(
          (p) => p.name == loggedInUserName,
        );
        emit(ProfileLoaded(currentUser: currentUser, family: family));
      } catch (e) {
        emit(
          const ProfileError('Data pengguna tidak cocok dengan data keluarga.'),
        );
      }
    });
  }

  Future<void> updateUserProfile(ParentModel updatedUser) async {
    emit(const ProfileLoading(message: 'Menyimpan perubahan...'));
    final result = await onboardingRepository.updateParentInCache(updatedUser);
    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      emit(const ProfileSuccess('Profil berhasil diperbarui.'));
      loadProfileData(); // Reload data
    });
  }

  Future<void> updateChildProfile(ChildModel updatedChild) async {
    emit(const ProfileLoading(message: 'Menyimpan perubahan...'));
    final result = await onboardingRepository.updateChildInCache(updatedChild);
    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      emit(const ProfileSuccess('Data anak berhasil diperbarui.'));
      loadProfileData(); // Reload data
    });
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (state is! ProfileLoaded) return;
    final currentUser = (state as ProfileLoaded).currentUser;

    emit(const ProfileLoading(message: 'Mengganti password...'));
    final result = await onboardingRepository.changePasswordInCache(
      userName: currentUser.name,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      emit(const ProfileSuccess('Password berhasil diganti.'));
      loadProfileData();
    });
  }

  Future<void> logout() async {
    emit(const ProfileLoading(message: 'Keluar...'));
    final result = await onboardingRepository.logout();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileLogoutSuccess()),
    );
  }
}
