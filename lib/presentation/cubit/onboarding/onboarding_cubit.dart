import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository onboardingRepository;

  OnboardingCubit({required this.onboardingRepository})
    : super(OnboardingInitial());

  Future<void> checkUniqueCode(String code) async {
    emit(OnboardingLoading());
    final result = await onboardingRepository.checkUniqueCode(code);
    result.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (family) => emit(OnboardingDataCollection(uniqueCode: family.uniqueCode)),
    );
  }

  void submitParentData({
    String? phoneNumber, // For new family flow
    required String name,
    required String password,
    required ParentRole role,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
  }) {
    final currentState = state is OnboardingDataCollection
        ? (state as OnboardingDataCollection)
        : const OnboardingDataCollection();

    emit(
      currentState.copyWith(
        phoneNumber: phoneNumber ?? currentState.phoneNumber,
        name: name,
        password: password,
        role: role,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
      ),
    );
  }

  void submitPregnancyStatus({
    required bool isPregnant,
    GestationalAge? gestationalAge,
  }) {
    if (state is OnboardingDataCollection) {
      emit(
        (state as OnboardingDataCollection).copyWith(
          isPregnant: isPregnant,
          gestationalAge: isPregnant ? gestationalAge : GestationalAge.none,
        ),
      );
    }
  }

  Future<void> submitLactationStatus({
    required bool isLactating,
    LactationPeriod? lactationPeriod,
  }) async {
    if (state is! OnboardingDataCollection) return;
    final currentData = state as OnboardingDataCollection;
    emit(OnboardingLoading());
    final data = currentData.copyWith(
      isLactating: isLactating,
      lactationPeriod: isLactating ? lactationPeriod : LactationPeriod.none,
    );

    final parent = ParentModel(
      name: data.name!,
      password: data.password!,
      role: data.role!,
      dateOfBirth: data.dateOfBirth!,
      height: data.height!,
      weight: data.weight!,
      isPregnant: data.isPregnant ?? false,
      gestationalAge: data.gestationalAge ?? GestationalAge.none, 
      isLactating: data.isLactating!,
      lactationPeriod: data.lactationPeriod!,
    );

    // Flow: Join existing family
    if (data.uniqueCode != null && data.uniqueCode!.isNotEmpty) {
      final result = await onboardingRepository.addParentToFamily(
        uniqueCode: data.uniqueCode!,
        parent: parent,
      );
      result.fold(
        (failure) => emit(OnboardingFailure(failure.message)),
        (_) => emit(
          OnboardingSuccess(
            FamilyModel(
              uniqueCode: data.uniqueCode!,
              phoneNumber: '',
              parents: [parent],
              children: [],
            ),
          ),
        ),
      );
    }
    // Flow: Create new family
    else {
      final family = FamilyModel(
        phoneNumber: data.phoneNumber!,
        uniqueCode: '', // BE will generate this
        parents: [parent],
        children: const [],
      );

      final result = await onboardingRepository.createNewFamily(family);
      result.fold(
        (failure) => emit(OnboardingFailure(failure.message)),
        (newFamily) =>
            emit(OnboardingSuccess(newFamily)), // Proceed to add child
      );
    }
  }

  Future<void> submitChildData({
    required String uniqueCode,
    required String name,
    required Gender gender,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
  }) async {
    emit(OnboardingLoading());

    final child = ChildModel(
      name: name,
      gender: gender,
      dateOfBirth: dateOfBirth,
      height: height,
      weight: weight,
    );

    final result = await onboardingRepository.updateFamilyWithChild(
      uniqueCode: uniqueCode,
      child: child,
    );

    result.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (updatedFamily) => emit(OnboardingSuccess(updatedFamily)),
    );
  }
}
