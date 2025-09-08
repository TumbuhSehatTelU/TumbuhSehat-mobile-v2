import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/family_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final OnboardingRepository onboardingRepository;

  ScanCubit({required this.onboardingRepository}) : super(ScanInitial());

  Future<void> loadFamilyData() async {
    emit(ScanLoading());
    final result = await onboardingRepository.getCachedFamily();
    result.fold(
      (failure) => emit(ScanError(failure.message)),
      (family) => emit(ScanLoaded(family)),
    );
  }
}
