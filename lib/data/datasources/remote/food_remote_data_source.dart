import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../models/meal_history_model.dart';

abstract class FoodRemoteDataSource {
  Future<void> postMealHistory(MealHistoryModel history);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final Dio client;

  FoodRemoteDataSourceImpl({required this.client});

  @override
  Future<void> postMealHistory(MealHistoryModel history) async {
    try {
      // TODO: endpoint
      final response = await client.post(
        '/api/meal-histories',
        data: history.toJson(),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        throw ServerException(
          'Failed to post meal history. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown network error',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}
