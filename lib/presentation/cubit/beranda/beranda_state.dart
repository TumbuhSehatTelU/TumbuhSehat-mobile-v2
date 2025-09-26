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
  final ParentModel currentUser;
  final RecommendationModel recommendation;

  const BerandaLoaded({
    required this.family,
    required this.currentUser,
    required this.recommendation,
  });

  @override
  List<Object> get props => [family, currentUser, recommendation];
}

class BerandaError extends BerandaState {
  final String message;

  const BerandaError(this.message);

  @override
  List<Object> get props => [message];
}
