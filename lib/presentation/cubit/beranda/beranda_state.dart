part of 'beranda_cubit.dart';

abstract class BerandaState extends Equatable {
  const BerandaState();

  @override
  List<Object> get props => [];
}

class BerandaInitial extends BerandaState {}

class BerandaLoading extends BerandaState {}

class BerandaLoaded extends BerandaState {
  final FamilyModel family;
  final dynamic currentUser;
  final RecommendationModel recommendationForToday;
  final RecommendationModel recommendationForTomorrow;
  final WeeklySummaryModel weeklySummary;
  final bool isChangingMember;
  final int initialMemberIndex;

  const BerandaLoaded({
    required this.family,
    required this.currentUser,
    required this.recommendationForToday,
    required this.recommendationForTomorrow,
    required this.weeklySummary,
    this.isChangingMember = false,
    required this.initialMemberIndex,
  });

  BerandaLoaded copyWith({
    FamilyModel? family,
    dynamic currentUser,
    RecommendationModel? recommendationForToday,
    RecommendationModel? recommendationForTomorrow,
    WeeklySummaryModel? weeklySummary,
    bool? isChangingMember,
    int? initialMemberIndex,
  }) {
    return BerandaLoaded(
      family: family ?? this.family,
      currentUser: currentUser ?? this.currentUser,
      recommendationForToday:
          recommendationForToday ?? this.recommendationForToday,
      recommendationForTomorrow:
          recommendationForTomorrow ?? this.recommendationForTomorrow,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      isChangingMember: isChangingMember ?? this.isChangingMember,
      initialMemberIndex: initialMemberIndex ?? this.initialMemberIndex,
    );
  }

  @override
  List<Object> get props => [
    family,
    currentUser,
    recommendationForToday,
    recommendationForTomorrow,
    weeklySummary,
    isChangingMember,
    initialMemberIndex,
  ];
}

class BerandaError extends BerandaState {
  final String message;

  const BerandaError(this.message);

  @override
  List<Object> get props => [message];
}
