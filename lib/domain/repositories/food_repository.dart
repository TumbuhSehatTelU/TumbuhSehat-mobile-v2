import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/child_model.dart';
import '../../data/models/meal_history_model.dart';
import '../../data/models/parent_model.dart';

abstract class FoodRepository {
  Future<Either<Failure, void>> saveMealHistory({
    required MealHistoryModel history,
    required List<ParentModel> parents,
    required List<ChildModel> children,
  });
}

// KONTRAK BE FOOD HISTORY
// {
//   "timestamp": 1678886400,
//   "eaters": {
//     "parent_ids": ["parent_uuid_1", "parent_uuid_2"],
//     "child_ids": ["child_uuid_5"]
//   },
//   "components": [
//     {
//       "food_name": "Nasi Putih",
//       "quantity": 2.0,
//       "urt_name": "Centong",
//       "total_grams": 200.0
//     },
//     {
//       "food_name": "Telur Dadar",
//       "quantity": 1.0,
//       "urt_name": "Butir",
//       "total_grams": 55.0
//     }
//   ]
// }

// Tabel 1: meal_histories
// id (UUID / BIGINT, Primary Key)
// family_id (UUID / BIGINT, Foreign Key)
// timestamp (TIMESTAMP)
// created_at (TIMESTAMP)
// updated_at (TIMESTAMP)
// Tabel 2: meal_components
// id (UUID / BIGINT, Primary Key)
// meal_history_id (UUID / BIGINT, Foreign Key ke meal_histories.id)
// food_name (VARCHAR(255))
// quantity (DECIMAL(8, 2))
// urt_name (VARCHAR(100))
// total_grams (DECIMAL(8, 2))
// Tabel 3: meal_eaters
// id (UUID / BIGINT, Primary Key)
// meal_history_id (UUID / BIGINT, Foreign Key ke meal_histories.id)
// parent_id (UUID / BIGINT, Foreign Key, Nullable)
// child_id (UUID / BIGINT, Foreign Key, Nullable)
