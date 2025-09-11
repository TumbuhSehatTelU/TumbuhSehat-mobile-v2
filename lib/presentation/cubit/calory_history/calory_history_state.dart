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

  const CaloryHistoryLoaded(this.summary);

  @override
  List<Object> get props => [summary];
}

class CaloryHistoryError extends CaloryHistoryState {
  final String message;

  const CaloryHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
