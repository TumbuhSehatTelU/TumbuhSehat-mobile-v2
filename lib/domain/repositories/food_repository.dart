import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/food_component_model.dart';
import '../../data/models/meal_history_model.dart';
import '../../data/models/serving_size_model.dart';

abstract class FoodRepository {
  Future<Either<Failure, List<FoodComponentModel>>> searchFoods(String query);
  Future<Either<Failure, List<ServingSizeModel>>> getServingSizes(int foodId);
  Future<Either<Failure, void>> saveMealHistory(MealHistoryModel meal);
}
