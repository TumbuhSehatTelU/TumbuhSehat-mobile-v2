import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../models/prediction_model.dart';

abstract class AnalysisRemoteDataSource {
  Future<PredictionResponseModel> predictImage(File imageFile);
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final Dio client;
  final String baseUrl = "https://Miuura-Nutrition.hf.space";

  AnalysisRemoteDataSourceImpl({required this.client});

  @override
  Future<PredictionResponseModel> predictImage(File imageFile) async {
    final url = "$baseUrl/predict";

    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'plate_cm': '26.0',
      });

      final response = await client.post(
        url,
        data: formData,
        options: Options(
          // Set timeout yang lebih lama karena inference butuh waktu
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return PredictionResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to predict image. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? e.message ?? 'Unknown network error',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}
