import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/local/food_local_data_source.dart';
import '../datasources/remote/food_remote_data_source.dart';
import '../models/food_component_model.dart';
import '../models/meal_history_model.dart';
import '../models/serving_size_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;
  final FoodLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FoodRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FoodComponentModel>>> searchFoods(
    String query,
  ) async {
    try {
      final foods = await localDataSource.searchFoods(query);
      return Right(foods);
    } catch (e) {
      return Left(
        CacheFailure('Gagal mencari data makanan dari database lokal.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ServingSizeModel>>> getServingSizes(
    int foodId,
  ) async {
    try {
      final servingSizes = await localDataSource.getServingSizes(foodId);
      return Right(servingSizes);
    } catch (e) {
      return Left(
        CacheFailure('Gagal mendapatkan ukuran saji dari database lokal.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveMealHistory(MealHistoryModel meal) async {
    try {
      await localDataSource.saveMealHistory(meal);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.postMealHistory(meal);
          // TODO: Implement logic to update `is_synced` status in local DB upon successful post
        } on ServerException catch (e) {
          print(
            'Failed to sync meal history: ${e.message}. Data is saved locally.',
          );
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Gagal menyimpan histori makanan di database lokal.'),
      );
    }
  }
}
