import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/local/onboarding_local_data_source.dart';
import '../datasources/remote/onboarding_remote_data_source.dart';
import '../models/child_model.dart';
import '../models/family_model.dart';
import '../models/parent_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;
  final OnboardingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OnboardingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FamilyModel>> getCachedFamily() async {
    try {
      final family = await localDataSource.getCachedFamily();
      return Right(family);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, FamilyModel>> checkUniqueCode(String code) async {
    if (await networkInfo.isConnected) {
      try {
        final family = await remoteDataSource.checkUniqueCode(code);
        return Right(family);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, FamilyModel>> createNewFamily(
    FamilyModel family,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newFamily = await remoteDataSource.createNewFamily(family);
        await localDataSource.cacheFamily(
          newFamily,
        ); // Cache after successful creation
        return Right(newFamily);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        await localDataSource.cacheFamily(family);
        return Right(family); // Return the local copy
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addParentToFamily({
    required String uniqueCode,
    required ParentModel parent,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addParentToFamily(uniqueCode, parent);
        // Optionally update local cache if needed, but might require fetching the whole family again
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, FamilyModel>> updateFamilyWithChild({
    required String uniqueCode,
    required ChildModel child,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedFamily = await remoteDataSource.updateFamilyWithChild(
          uniqueCode,
          child,
        );
        await localDataSource.cacheFamily(updatedFamily);
        return Right(updatedFamily);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedFamily = await localDataSource.getCachedFamily();
        final updatedChildren = [...cachedFamily.children, child];
        final updatedFamily = FamilyModel(
          phoneNumber: cachedFamily.phoneNumber,
          uniqueCode: cachedFamily.uniqueCode,
          parents: cachedFamily.parents,
          children: updatedChildren,
        );
        await localDataSource.cacheFamily(updatedFamily);
        return Right(updatedFamily);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, FamilyModel>> login({
    required String name,
    required String password,
    required bool rememberMe,
    String? uniqueCode,
    String? phoneNumber,
  }) async {
    Future<void> handleSessionPersistence(FamilyModel family) async {
      if (rememberMe) {
        await localDataSource.cacheFamily(family);
      } else {
        await localDataSource.clearCachedFamily();
      }
    }

    if (await networkInfo.isConnected) {
      if (uniqueCode == null || uniqueCode.isEmpty) {
        return const Left(
          ServerFailure("Unique code is required for online login."),
        );
      }
      try {
        final family = await remoteDataSource.login(uniqueCode, name, password);
        await handleSessionPersistence(family);
        return Right(family);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      if (phoneNumber == null || phoneNumber.isEmpty) {
        return const Left(
          CacheFailure("Nomor handphone diperlukan untuk login offline."),
        );
      }
      try {
        final family = await localDataSource.getCachedFamily();
        
        if (family.phoneNumber != phoneNumber) {
          return const Left(
            CacheFailure(
              'Data keluarga untuk nomor ini tidak ditemukan di cache.',
            ),
          );
        }

        final parentExists = family.parents.any(
          (parent) => parent.name == name && parent.password == password,
        );

        if (parentExists) {
          await handleSessionPersistence(family);
          return Right(family);
        } else {
          return const Left(
            CacheFailure('Nama atau password salah untuk mode offline.'),
          );
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
}
