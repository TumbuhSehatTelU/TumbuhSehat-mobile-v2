import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../../../domain/repositories/chatbot_repository.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotRepository chatbotRepository;
  final types.User _user = const types.User(id: 'user');
  final types.User _bot = const types.User(
    id: 'bot',
    firstName: 'Sobat TumbuhSehat',
  );
  String? _threadId;

  ChatbotCubit({required this.chatbotRepository})
    : super(const ChatbotInitial());

  void loadInitialMessage() {
    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          'Halo! Saya Sobat TumbuhSehat, ada yang bisa saya bantu seputar gizi keluarga Anda?',
    );
    emit(ChatbotLoaded(messages: [botMessage]));
  }

  void sendMessage(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    // Add user message to UI instantly
    final updatedMessages = [userMessage, ...state.messages];
    emit(ChatbotLoading(messages: updatedMessages));

    final result = await chatbotRepository.getChatResponse(
      message: message.text,
      threadId: _threadId,
    );

    result.fold(
      (failure) {
        final errorMessage = types.TextMessage(
          author: _bot,
          id: const Uuid().v4(),
          text: 'Error: ${failure.message}',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        emit(
          ChatbotError(
            message: failure.message,
            messages: [errorMessage, ...updatedMessages],
          ),
        );
      },
      (response) {
        // Assuming the response is just the string.
        // If it includes the threadId, you should parse and save it.
        // For simplicity, we assume the first response contains the new threadId.
        if (_threadId == null) {
          // This is a simplified assumption. A proper implementation
          // would return the threadId from the repository.
        }

        final botMessage = types.TextMessage(
          author: _bot,
          id: const Uuid().v4(),
          text: response,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        emit(ChatbotLoaded(messages: [botMessage, ...updatedMessages]));
      },
    );
  }
}
