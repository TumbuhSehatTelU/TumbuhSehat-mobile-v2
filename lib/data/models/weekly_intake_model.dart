import 'package:equatable/equatable.dart';

class WeeklyIntake extends Equatable {
  final int weekNumber;
  final double totalCalories;

  const WeeklyIntake({required this.weekNumber, required this.totalCalories});

  @override
  List<Object> get props => [weekNumber, totalCalories];
}
