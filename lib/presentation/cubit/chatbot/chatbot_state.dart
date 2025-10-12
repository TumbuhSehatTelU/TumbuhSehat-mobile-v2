part of 'chatbot_cubit.dart';

abstract class ChatbotState extends Equatable {
  final List<types.Message> messages;
  const ChatbotState({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatbotInitial extends ChatbotState {
  const ChatbotInitial() : super(messages: const []);
}

class ChatbotLoaded extends ChatbotState {
  const ChatbotLoaded({required super.messages});
}

class ChatbotLoading extends ChatbotState {
  const ChatbotLoading({required super.messages});
}

class ChatbotError extends ChatbotState {
  final String message;
  const ChatbotError({required this.message, required super.messages});

  @override
  List<Object> get props => [message, messages];
}
