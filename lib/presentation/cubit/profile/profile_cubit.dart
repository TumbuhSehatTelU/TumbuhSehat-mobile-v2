import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_tumbuh_sehat_v2/domain/repositories/nutrition_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../../core/database/database_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../login/login_cubit.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final OnboardingRepository onboardingRepository;
  final SharedPreferences sharedPreferences;
  final NutritionRepository nutritionRepository;
  final NotificationService notificationService;

  ProfileCubit({
    required this.onboardingRepository,
    required this.sharedPreferences,
    required this.nutritionRepository,
    required this.notificationService,
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

  Future<void> generateDummyData() async {
    emit(const ProfileLoading(message: 'Membuat data dummy...'));
    final result = await nutritionRepository.generateDummyHistory();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileSuccess('Data dummy berhasil dibuat.')),
    );
  }

  void triggerTestNotification() {
    if (state is! ProfileLoaded) {
      emit(const ProfileError('Data profil belum dimuat.'));
      return;
    }
    final currentUser = (state as ProfileLoaded).currentUser;

    // Contoh variasi notifikasi
    final notifications = [
      {
        'title': 'Waktunya Makan Siang! 🥗',
        'body':
            'Sudah cek rekomendasi makan siang untuk keluarga hari ini, Bu?',
      },
      {
        'title': 'Gizi Seimbang, Anak Senang 😊',
        'body':
            'Jangan lupa pantau asupan gizi si Kecil. Cek rekomendasinya sekarang!',
      },
      {
        'title': 'Halo, Sobat TumbuhSehat!',
        'body':
            'Asupan gizi seimbang menanti. Lihat rekomendasi menu harian Anda.',
      },
    ];
    final randomNotification =
        notifications[Random().nextInt(notifications.length)];

    notificationService.showNotification(
      title: randomNotification['title']!,
      body: randomNotification['body']!,
      payload: 'recommendation_${currentUser.name}',
    );

    // Beri feedback ke UI bahwa notifikasi berhasil di-trigger
    emit(const ProfileSuccess('Notifikasi tes berhasil dikirim.'));
    // Kembali ke state loaded agar UI tidak berubah
    Future.delayed(const Duration(seconds: 2), () => loadProfileData());
  }
}
