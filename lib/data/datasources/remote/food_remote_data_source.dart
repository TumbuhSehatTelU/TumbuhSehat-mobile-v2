import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../models/meal_history_model.dart';

abstract class FoodRemoteDataSource {
  Future<void> postMealHistory(MealHistoryModel meal);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final Dio client;
  FoodRemoteDataSourceImpl({required this.client});

  @override
  Future<void> postMealHistory(MealHistoryModel meal) async {
    try {
      // TODO: endpoint BE
      final response = await client.post('/meal-history', data: meal.toJson());
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Failed to post meal history. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Unknown network error',
      );
    }
  }
}
