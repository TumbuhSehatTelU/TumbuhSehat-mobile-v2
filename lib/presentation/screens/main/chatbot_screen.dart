import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/responsive_helper.dart';
import '../../../gen/assets.gen.dart';
import '../../../injection_container.dart';
import '../../cubit/chatbot/chatbot_cubit.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _user = const types.User(id: 'user');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatbotCubit>()..loadInitialMessage(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chatbot Gizi')),
        body: BlocBuilder<ChatbotCubit, ChatbotState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.pattern.path),
                  // Gunakan helper responsif untuk memilih fit
                  fit: ResponsiveHelper(context).isTablet
                      ? BoxFit.fill
                      : BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Chat(
                messages: state.messages,
                onSendPressed: (partialText) {
                  context.read<ChatbotCubit>().sendMessage(partialText);
                },
                user: _user,
                showUserAvatars: false,
                showUserNames: false,
                // isTyping: state is ChatbotLoading,
                theme: DefaultChatTheme(
                  // Kustomisasi UI chat di sini
                  backgroundColor:
                      Colors.transparent, // Agar background terlihat
                  primaryColor: Theme.of(context).primaryColor,
                  secondaryColor: Colors.grey.shade200,
                  inputBackgroundColor: Colors.white,
                  inputTextColor: Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
