import 'dart:io';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
import '../../../data/datasources/remote/analysis_remote_datasource.dart';
import '../../../data/models/prediction_model.dart';

part 'food_prediction_state.dart';

class FoodPredictionCubit extends Cubit<FoodPredictionState> {
  final AnalysisRemoteDataSource remoteDataSource;

  FoodPredictionCubit({required this.remoteDataSource})
    : super(FoodPredictionInitial());

  Future<void> predictFood(XFile imageFile) async {
    emit(FoodPredictionLoading());
    try {
      final result = await remoteDataSource.predictImage(File(imageFile.path));
      emit(FoodPredictionLoaded(result));
    } on ServerException catch (e) {
      emit(FoodPredictionError(e.message));
    } catch (e) {
      emit(FoodPredictionError('Terjadi kesalahan yang tidak terduga: $e'));
    }
  }
}
