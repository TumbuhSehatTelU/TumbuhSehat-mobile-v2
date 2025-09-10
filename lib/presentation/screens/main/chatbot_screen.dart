import 'package:flutter/widgets.dart';

import '../../widgets/layouts/ts_page_scaffold.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(body: Center(child: Text('Chatbot Screen')));
  }
}
