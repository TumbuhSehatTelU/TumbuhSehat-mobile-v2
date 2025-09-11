import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/weekly_summary_model.dart';

abstract class NutritionRepository {
  Future<Either<Failure, WeeklySummaryModel>> getWeeklySummary({
    required dynamic member,
    required DateTime targetDate,
  });
}
