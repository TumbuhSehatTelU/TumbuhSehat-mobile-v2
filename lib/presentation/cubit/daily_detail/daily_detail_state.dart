part of 'daily_detail_cubit.dart';

abstract class DailyDetailState extends Equatable {
  const DailyDetailState();

  @override
  List<Object> get props => [];
}

class DailyDetailInitial extends DailyDetailState {}

class DailyDetailLoading extends DailyDetailState {}

class DailyDetailLoaded extends DailyDetailState {
  final DailyDetailModel detail;
  final List<dynamic> allMembers;
  final dynamic currentMember;

  const DailyDetailLoaded({
    required this.detail,
    required this.allMembers,
    required this.currentMember,
  });

  @override
  List<Object> get props => [detail, allMembers, currentMember];
}

class DailyDetailError extends DailyDetailState {
  final String message;

  const DailyDetailError(this.message);

  @override
  List<Object> get props => [message];
}
