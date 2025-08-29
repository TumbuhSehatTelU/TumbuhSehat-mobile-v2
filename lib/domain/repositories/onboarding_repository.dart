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
    String? uniqueCode,
    required String name,
    required String password,
  });
}
