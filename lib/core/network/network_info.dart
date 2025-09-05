// ignore_for_file: unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final Dio dio;

  static bool _forceOffline = true;

  static void setForceOffline(bool value) {
    _forceOffline = value;
  }

  NetworkInfoImpl(this.connectivity, this.dio);

  @override
  Future<bool> get isConnected async {
    if (_forceOffline) {
      return false;
    }
    
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      // POSTPONE API BE
      final response = await dio.get(
        '/',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }
}
