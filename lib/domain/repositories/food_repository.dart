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

// KONTRAK BE FOOD HISTORY
// {
//     "familyUniqueCode": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
//     "mealTimestamp": "2023-11-21T08:45:15.123Z",
//     "eaters": {
//         "parents": [
//             {
//                 "name": "Tono",
//                 "role": "Ayah"
//             }
//         ],
//         "children": [
//             {
//                 "name": "Toni",
//                 "dateOfBirth": "2022-01-10"
//             }
//         ]
//     },
//     "mealComponents": [
//         {
//             "foodName": "Nasi Putih",
//             "quantity": 1.5,
//             "urtName": "Centong",
//             "massInGrams": 150.0,
//             "nutritions": {
//                 "calories": 193.5,
//                 "protein": 3.6,
//                 "fat": 0.3,
//                 "carbohydrates": 41.85
//             }
//         },
//         {
//             "foodName": "Tempe Goreng",
//             "quantity": 2.0,
//             "urtName": "Potong Sedang",
//             "massInGrams": 50.0,
//             "nutritions": {
//                 "calories": 130.0,
//                 "protein": 11.0,
//                 "fat": 8.0,
//                 "carbohydrates": 5.0
//             }
//         }
//     ],
//     "totalNutritions": {
//         "calories": 323.5,
//         "protein": 14.6,
//         "fat": 8.3,
//         "carbohydrates": 46.85
//     },
//     "analysisMethod": "MANUAL_INPUT"
// }