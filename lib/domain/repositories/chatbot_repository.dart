import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class ChatbotRepository {
  Future<Either<Failure, String>> getChatResponse({
    required String message,
    String? threadId,
  });
}
