part of 'calory_history_cubit.dart';

abstract class CaloryHistoryState extends Equatable {
  const CaloryHistoryState();

  @override
  List<Object> get props => [];
}

class CaloryHistoryInitial extends CaloryHistoryState {}

class CaloryHistoryLoading extends CaloryHistoryState {}

class CaloryHistoryLoaded extends CaloryHistoryState {
  final WeeklySummaryModel summary;
  final List<dynamic> allMembers;
  final dynamic currentMember;
  final List<WeeklyIntake> monthlyTrend;
  final DateTime displayedMonth;

  const CaloryHistoryLoaded({
    required this.summary,
    required this.allMembers,
    required this.currentMember,
    required this.monthlyTrend,
    required this.displayedMonth,
  });

  @override
  List<Object> get props => [
    summary,
    allMembers,
    currentMember,
    monthlyTrend,
    displayedMonth,
  ];
}

class CaloryHistoryError extends CaloryHistoryState {
  final String message;

  const CaloryHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
