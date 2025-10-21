part of 'scan_analysis_cubit.dart';

abstract class ScanAnalysisState extends Equatable {
  const ScanAnalysisState();

  @override
  List<Object> get props => [];
}

class ScanAnalysisInitial extends ScanAnalysisState {}

class ScanAnalysisLoading extends ScanAnalysisState {}

class ScanAnalysisSuccess extends ScanAnalysisState {}

class ScanAnalysisWarning extends ScanAnalysisState {
  final Set<String> deficientNutrients;
  final List<String> deficientMembers;

  const ScanAnalysisWarning({
    required this.deficientNutrients,
    required this.deficientMembers,
  });

  @override
  List<Object> get props => [deficientNutrients, deficientMembers];
}

class ScanAnalysisError extends ScanAnalysisState {
  final String message;

  const ScanAnalysisError(this.message);

  @override
  List<Object> get props => [message];
}
