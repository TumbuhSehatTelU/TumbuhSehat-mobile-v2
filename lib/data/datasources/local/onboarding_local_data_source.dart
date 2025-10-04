// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';
import '../../../presentation/cubit/login/login_cubit.dart';
import '../../models/family_model.dart';

abstract class OnboardingLocalDataSource {
  Future<void> cacheFamily(FamilyModel family);
  Future<FamilyModel> getCachedFamily();
  Future<FamilyModel> loginOffline(String name, String password);
  Future<void> clearCachedFamily();
  Future<void> clearAllData();
  Future<void> clearHistoryAndOverrides();
}

const String CACHED_FAMILY = 'CACHED_FAMILY';

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheFamily(FamilyModel family) async {
    try {
      final jsonString = json.encode(family.toJson());
      final success = await sharedPreferences.setString(
        CACHED_FAMILY,
        jsonString,
      );
      if (!success) {
        throw CacheException('Failed to write to SharedPreferences.');
      }
    } catch (e) {
      throw CacheException('Failed to cache the family data.');
    }
  }

  @override
  Future<FamilyModel> getCachedFamily() {
    final jsonString = sharedPreferences.getString(CACHED_FAMILY);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final model = FamilyModel.fromJson(json.decode(jsonString));
        return Future.value(model);
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

  @override
  Future<void> clearCachedFamily() {
    return sharedPreferences.remove(CACHED_FAMILY);
  }

  @override
  Future<void> clearAllData() async {
    await sharedPreferences.clear();
  }

  @override
  Future<void> clearHistoryAndOverrides() async {
    final allKeys = sharedPreferences.getKeys();
    for (final key in allKeys) {
      if (key != CACHED_FAMILY && key != LOGGED_IN_USER_NAME_KEY) {
        await sharedPreferences.remove(key);
      }
    }
  }
}
