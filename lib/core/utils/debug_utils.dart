import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

Future<void> clearTumbuhSehatPreferencesOnDebug() async {
  if (kDebugMode) {
    print('[DEBUG] === MEMBERSIHKAN DATA APLIKASI LAMA ===');
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    int clearedKeys = 0;

    const List<String> tumbuhSehatKeywords = [
      'CACHED_FAMILY', // Dari OnboardingLocalDataSource
      'LOGGED_IN_USER_NAME', // Dari LoginCubit
      'recommendation_overrides_', // Dari RecommendationRepository
      'unique_code_failure_count', // Dari EnterUniqueCodeScreen
      'unique_code_penalty_release_time', // Dari EnterUniqueCodeScreen
      // Tambahkan key lain yang mungkin Anda buat di masa depan
    ];

    for (final key in allKeys) {
      // Cek apakah key mengandung salah satu keyword
      bool isTumbuhSehatKey = tumbuhSehatKeywords.any(
        (keyword) => key.startsWith(keyword),
      );

      if (isTumbuhSehatKey) {
        await prefs.remove(key);
        print('[DEBUG] Menghapus key: $key');
        clearedKeys++;
      }
    }
    print('[DEBUG] === Pembersihan selesai. $clearedKeys key dihapus. ===');
  }
}

Future<void> deleteDatabaseOnDebug() async {
  if (kDebugMode) {
    print('[DEBUG] === MENGHAPUS FILE DATABASE LAMA ===');
    try {
      final dbPath = await getDatabasesPath();
      final path = join(
        dbPath,
        'app_database.db',
      ); 
      await deleteDatabase(path);
      print('[DEBUG] === Database berhasil dihapus. ===');
    } catch (e) {
      print('[DEBUG] Gagal menghapus database: $e');
    }
  }
}
