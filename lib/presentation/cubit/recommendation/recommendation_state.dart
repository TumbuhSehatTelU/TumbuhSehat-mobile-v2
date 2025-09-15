part of 'recommendation_cubit.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final RecommendationModel recommendation;
  final DateTime displayedDate;
  final dynamic currentMember;
  final List<dynamic> allMembers;

  const RecommendationLoaded({
    required this.recommendation,
    required this.displayedDate,
    required this.currentMember,
    required this.allMembers,
  });

  @override
  List<Object> get props => [
    recommendation,
    displayedDate,
    currentMember,
    allMembers,
  ];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object> get props => [message];
}
