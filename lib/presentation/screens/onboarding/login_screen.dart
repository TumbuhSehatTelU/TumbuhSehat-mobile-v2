import 'package:flutter/material.dart';

import '../../widgets/ts_page_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(body: Center(child: Text('Halaman Login')));
  }
}
