import 'package:flutter/material.dart';
import '../../widgets/ts_page_scaffold.dart';

class ParentRegistrationScreen extends StatelessWidget {
  final bool isJoiningFamily;

  const ParentRegistrationScreen({super.key, required this.isJoiningFamily});

  @override
  Widget build(BuildContext context) {
    return TSPageScaffold(
      appBar: AppBar(title: const Text('Registrasi Data Diri')),
      body: Center(
        child: Text(
          isJoiningFamily
              ? 'UI untuk bergabung dengan keluarga.'
              : 'UI untuk membuat keluarga baru.',
        ),
      ),
    );
  }
}
