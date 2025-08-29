import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../models/child_model.dart';
import '../../models/family_model.dart';
import '../../models/parent_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<FamilyModel> checkUniqueCode(String code);
  Future<FamilyModel> createNewFamily(FamilyModel family);
  Future<void> addParentToFamily(String uniqueCode, ParentModel parent);
  Future<FamilyModel> updateFamilyWithChild(
    String uniqueCode,
    ChildModel child,
  );
  Future<FamilyModel> login(String uniqueCode, String name, String password);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final Dio client;

  OnboardingRemoteDataSourceImpl({required this.client});

  @override
  Future<FamilyModel> checkUniqueCode(String code) async {
    try {
      // POSTPONE
      final response = await client.get('/families/$code');
      if (response.statusCode == 200) {
        return FamilyModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to check unique code. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown network error');
    }
  }

  @override
  Future<FamilyModel> createNewFamily(FamilyModel family) async {
    try {
      // POSTPONE
      final response = await client.post('/families', data: family.toJson());
      if (response.statusCode == 201) {
        return FamilyModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to create new family. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown network error');
    }
  }

  @override
  Future<void> addParentToFamily(String uniqueCode, ParentModel parent) async {
    try {
      // POSTPONE
      final response = await client.post(
        '/families/$uniqueCode/parents',
        data: parent.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Failed to add parent. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown network error');
    }
  }

  @override
  Future<FamilyModel> updateFamilyWithChild(
    String uniqueCode,
    ChildModel child,
  ) async {
    try {
      // POSTPONE
      final response = await client.post(
        '/families/$uniqueCode/children',
        data: child.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FamilyModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to update family with child. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown network error');
    }
  }

  @override
  Future<FamilyModel> login(
    String uniqueCode,
    String name,
    String password,
  ) async {
    try {
      // POSTPONE
      final response = await client.post(
        '/auth/login',
        data: {'uniqueCode': uniqueCode, 'name': name, 'password': password},
      );
      if (response.statusCode == 200) {
        return FamilyModel.fromJson(
          response.data['family'],
        );
      } else {
        throw ServerException(
          'Login failed. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw ServerException(
          e.response?.data['message'] ?? 'Invalid credentials',
        );
      }
      throw ServerException(e.message ?? 'Unknown network error');
    }
  }
}
