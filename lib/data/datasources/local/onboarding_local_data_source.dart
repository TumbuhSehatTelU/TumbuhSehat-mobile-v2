// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';
import '../../models/family_model.dart';

abstract class OnboardingLocalDataSource {
  Future<void> cacheFamily(FamilyModel family);
  Future<FamilyModel> getCachedFamily();
  Future<FamilyModel> loginOffline(String name, String password);
}

const String CACHED_FAMILY = 'CACHED_FAMILY';

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheFamily(FamilyModel family) {
    try {
      final jsonString = json.encode(family.toJson());
      return sharedPreferences.setString(CACHED_FAMILY, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache the family data.');
    }
  }

  @override
  Future<FamilyModel> getCachedFamily() {
    final jsonString = sharedPreferences.getString(CACHED_FAMILY);
    if (jsonString != null) {
      try {
        return Future.value(FamilyModel.fromJson(json.decode(jsonString)));
      } catch (e) {
        throw CacheException('Error parsing cached data.');
      }
    } else {
      throw CacheException('No cached family found.');
    }
  }

  @override
  Future<FamilyModel> loginOffline(String name, String password) async {
    try {
      final family = await getCachedFamily();
      final parentExists = family.parents.any(
        (parent) => parent.name == name && parent.password == password,
      );

      if (parentExists) {
        return family;
      } else {
        throw CacheException('Invalid name or password.');
      }
    } on CacheException {
      rethrow; // Rethrow specific exceptions from getCachedFamily or login check
    } catch (e) {
      throw CacheException('An unknown error occurred during offline login.');
    }
  }
}
