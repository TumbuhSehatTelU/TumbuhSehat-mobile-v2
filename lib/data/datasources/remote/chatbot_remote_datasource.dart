import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/error/exceptions.dart';

abstract class ChatbotRemoteDataSource {
  Future<String> getChatResponse(String message, String? threadId);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final Dio client;
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;
  final String assistantId = dotenv.env['OPENAI_ASSISTANT_ID']!;
  final String openAiUrl = 'https://api.openai.com/v1';

  ChatbotRemoteDataSourceImpl({required this.client});

  @override
  Future<String> getChatResponse(String message, String? threadId) async {
    try {
      // Step 1: Create a thread if it doesn't exist
      String currentThreadId = threadId ?? await _createThread();

      // Step 2: Add a message to the thread
      await _addMessageToThread(currentThreadId, message);

      // Step 3: Create a run
      final runId = await _createRun(currentThreadId);

      // Step 4: Wait for the run to complete
      await _waitForRunCompletion(currentThreadId, runId);

      // Step 5: Retrieve the latest message from the assistant
      return await _getLatestAssistantMessage(currentThreadId);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?['message'] ?? 'Network error',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  Future<String> _createThread() async {
    final response = await client.post(
      '$openAiUrl/threads',
      options: _getHeaders(),
    );
    return response.data['id'];
  }

  Future<void> _addMessageToThread(String threadId, String message) async {
    await client.post(
      '$openAiUrl/threads/$threadId/messages',
      data: {'role': 'user', 'content': message},
      options: _getHeaders(),
    );
  }

  Future<String> _createRun(String threadId) async {
    final response = await client.post(
      '$openAiUrl/threads/$threadId/runs',
      data: {'assistant_id': assistantId},
      options: _getHeaders(),
    );
    return response.data['id'];
  }

  Future<void> _waitForRunCompletion(String threadId, String runId) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final response = await client.get(
        '$openAiUrl/threads/$threadId/runs/$runId',
        options: _getHeaders(),
      );
      final status = response.data['status'];
      if (status == 'completed') {
        break;
      }
      if (status == 'failed' || status == 'cancelled' || status == 'expired') {
        throw ServerException('Run failed with status: $status');
      }
    }
  }

  Future<String> _getLatestAssistantMessage(String threadId) async {
    final response = await client.get(
      '$openAiUrl/threads/$threadId/messages',
      options: _getHeaders(),
    );
    final messages = response.data['data'] as List;
    final assistantMessage = messages.firstWhere(
      (msg) => msg['role'] == 'assistant',
      orElse: () => null,
    );
    if (assistantMessage != null && assistantMessage['content'].isNotEmpty) {
      return assistantMessage['content'][0]['text']['value'];
    }
    return 'Maaf, saya tidak bisa merespons saat ini.';
  }

  Options _getHeaders() {
    return Options(
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      },
    );
  }
}
