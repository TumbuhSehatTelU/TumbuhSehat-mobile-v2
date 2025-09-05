import 'package:flutter/material.dart';

import '../../widgets/ts_page_scaffold.dart';

class PregnancyCheckScreen extends StatefulWidget {
  const PregnancyCheckScreen({super.key});

  @override
  State<PregnancyCheckScreen> createState() => _PregnancyCheckScreenState();
}

class _PregnancyCheckScreenState extends State<PregnancyCheckScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(
      body: Center(child: Text('Halaman cek kehamilan')),
    );
  }
}
