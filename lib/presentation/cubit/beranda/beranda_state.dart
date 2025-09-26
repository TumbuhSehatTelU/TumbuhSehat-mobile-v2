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

  const BerandaLoaded({
    required this.family,
    required this.currentUser,
    required this.recommendationForToday,
    required this.recommendationForTomorrow,
  });

  @override
  List<Object> get props => [
    family,
    currentUser,
    recommendationForToday,
    recommendationForTomorrow,
  ];
}

class BerandaError extends BerandaState {
  final String message;

  const BerandaError(this.message);

  @override
  List<Object> get props => [message];
}
