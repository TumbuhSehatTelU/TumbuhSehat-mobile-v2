import 'package:flutter/material.dart';

import '../../widgets/ts_page_scaffold.dart';

class LactationCheckScreen extends StatefulWidget {
  const LactationCheckScreen({super.key});

  @override
  State<LactationCheckScreen> createState() => _LactationCheckScreenState();
}

class _LactationCheckScreenState extends State<LactationCheckScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(
      body: Center(child: Text('Halaman cek menyusui')),
    );
  }
}
