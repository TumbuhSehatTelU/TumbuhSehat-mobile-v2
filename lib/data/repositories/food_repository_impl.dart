import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/local/food_local_data_source.dart';
import '../datasources/remote/food_remote_data_source.dart';
import '../models/child_model.dart';
import '../models/food_model.dart';
import '../models/meal_history_model.dart';
import '../models/parent_model.dart';
import '../models/urt_model.dart';

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
  Future<Either<Failure, void>> saveMealHistory({
    required MealHistoryModel history,
    required List<ParentModel> parents,
    required List<ChildModel> children,
  }) async {
    try {
      await localDataSource.saveMealHistory(history, parents, children);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.postMealHistory(history);
          // TODO: Buat method `updateSyncStatus` di LocalDataSource
        } on ServerException catch (e) {
          print('Failed to sync meal history: ${e.message}');
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<FoodModel>>> searchFoods(String query) async {
    try {
      final foods = await localDataSource.searchFoods(query);
      return Right(foods);
    } catch (e) {
      return Left(CacheFailure('Gagal mencari data makanan: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UrtModel>>> getUrtsForFood(int foodId) async {
    try {
      final urts = await localDataSource.getUrtsForFood(foodId);
      return Right(urts);
    } catch (e) {
      return Left(CacheFailure('Gagal mendapatkan URT: $e'));
    }
  }
}
