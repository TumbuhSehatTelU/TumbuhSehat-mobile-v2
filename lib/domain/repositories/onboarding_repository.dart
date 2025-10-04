import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/child_model.dart';
import '../../data/models/family_model.dart';
import '../../data/models/parent_model.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, FamilyModel>> getCachedFamily();
  Future<Either<Failure, FamilyModel>> checkUniqueCode(String code);
  Future<Either<Failure, FamilyModel>> createNewFamily(FamilyModel family);
  Future<Either<Failure, void>> addParentToFamily({
    required String uniqueCode,
    required ParentModel parent,
  });
  Future<Either<Failure, FamilyModel>> updateFamilyWithChild({
    required String uniqueCode,
    required ChildModel child,
  });
  Future<Either<Failure, FamilyModel>> login({
    required String name,
    required String password,
    required bool rememberMe,
    String? uniqueCode,
    String? phoneNumber,
  });
  Future<Either<Failure, void>> clearAllLocalData();
  Future<Either<Failure, void>> clearNonFamilyData();
  Future<Either<Failure, void>> updateParentInCache(ParentModel updatedParent);
  Future<Either<Failure, void>> updateChildInCache(ChildModel updatedChild);
  Future<Either<Failure, void>> changePasswordInCache({
    required String userName,
    required String oldPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> logout();
}
