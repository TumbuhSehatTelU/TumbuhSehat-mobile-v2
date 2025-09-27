
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/database_helper.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final OnboardingRepository onboardingRepository;
  final DatabaseHelper databaseHelper;

  ProfileCubit({
    required this.onboardingRepository,
    required this.databaseHelper,
  }) : super(ProfileInitial());

  Future<void> deleteAllData() async {
    emit(const ProfileLoading('Menghapus semua data lokal...'));
    final result = await onboardingRepository.clearAllLocalData();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileSuccess('Semua data berhasil dihapus.')),
    );
  }

  Future<void> deleteHistoryData() async {
    emit(const ProfileLoading('Menghapus riwayat & cache...'));
    final result = await onboardingRepository.clearNonFamilyData();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileSuccess('Riwayat & cache berhasil dihapus.')),
    );
  }

  Future<void> reseedDatabase() async {
    emit(const ProfileLoading('Memuat ulang data dasar makanan...'));
    try {
      await databaseHelper.reseedDatabase();
      emit(const ProfileSuccess('Data dasar berhasil dimuat ulang.'));
    } catch (e) {
      emit(ProfileError('Gagal memuat ulang data: $e'));
    }
  }
}
