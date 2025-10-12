import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/remote/chatbot_remote_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getChatResponse({
    required String message,
    String? threadId,
  }) async {
    try {
      final response = await remoteDataSource.getChatResponse(
        message,
        threadId,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
