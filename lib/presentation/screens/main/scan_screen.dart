import 'package:flutter/material.dart';
import '../../widgets/ts_page_scaffold.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return TSPageScaffold(
      appBar: AppBar(title: const Text('Scan Makanan')),
      body: Center(child: Text('Scan Screen')),
    );
  }
}
