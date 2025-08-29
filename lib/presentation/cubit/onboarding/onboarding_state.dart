part of 'onboarding_cubit.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingSuccess extends OnboardingState {
  final FamilyModel family;

  const OnboardingSuccess(this.family);

  @override
  List<Object> get props => [family];
}

class OnboardingFailure extends OnboardingState {
  final String message;

  const OnboardingFailure(this.message);

  @override
  List<Object> get props => [message];
}

class OnboardingDataCollection extends OnboardingState {
  // Family identifiers
  final String? uniqueCode;
  final String? phoneNumber;

  // Parent details
  final String? name;
  final String? password;
  final ParentRole? role;
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;

  // Mother-specific details
  final bool? isPregnant;
  final GestationalAge? gestationalAge;
  final bool? isLactating;
  final LactationPeriod? lactationPeriod;

  const OnboardingDataCollection({
    this.uniqueCode,
    this.phoneNumber,
    this.name,
    this.password,
    this.role,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.isPregnant,
    this.gestationalAge,
    this.isLactating,
    this.lactationPeriod,
  });

  OnboardingDataCollection copyWith({
    String? uniqueCode,
    String? phoneNumber,
    String? name,
    String? password,
    ParentRole? role,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
    bool? isPregnant,
    GestationalAge? gestationalAge,
    bool? isLactating,
    LactationPeriod? lactationPeriod,
  }) {
    return OnboardingDataCollection(
      uniqueCode: uniqueCode ?? this.uniqueCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      password: password ?? this.password,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      isPregnant: isPregnant ?? this.isPregnant,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      isLactating: isLactating ?? this.isLactating,
      lactationPeriod: lactationPeriod ?? this.lactationPeriod,
    );
  }

  @override
  List<Object?> get props => [
    uniqueCode,
    phoneNumber,
    name,
    password,
    role,
    dateOfBirth,
    height,
    weight,
    isPregnant,
    gestationalAge,
    isLactating,
    lactationPeriod,
  ];
}
