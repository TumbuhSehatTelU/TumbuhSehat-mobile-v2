import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // CORE
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl(), sl()));

  // EXTERNAL
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  // POSTPONE BE URL
  sl.registerLazySingleton(
    () => Dio(BaseOptions(baseUrl: 'https://tumbuhsehat.com')),
  );
  sl.registerLazySingleton(() => Connectivity());
}
