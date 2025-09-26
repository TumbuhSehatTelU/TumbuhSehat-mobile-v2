part of 'food_prediction_cubit.dart';

abstract class FoodPredictionState extends Equatable {
  const FoodPredictionState();

  @override
  List<Object> get props => [];
}

class FoodPredictionInitial extends FoodPredictionState {}

class FoodPredictionLoading extends FoodPredictionState {}

class FoodPredictionLoaded extends FoodPredictionState {
  final PredictionResponseModel result;

  const FoodPredictionLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class FoodPredictionError extends FoodPredictionState {
  final String message;

  const FoodPredictionError(this.message);

  @override
  List<Object> get props => [message];
}
