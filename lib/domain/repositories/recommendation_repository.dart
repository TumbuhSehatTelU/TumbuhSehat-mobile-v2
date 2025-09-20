import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/recommendation_model.dart';

abstract class RecommendationRepository {
  Future<Either<Failure, RecommendationModel>> getMealRecommendation({
    required dynamic member,
    required DateTime forDate,
  });

  Future<Either<Failure, List<RecommendedFood>>> getAlternatives({
    required RecommendedFood originalFood,
  });
}