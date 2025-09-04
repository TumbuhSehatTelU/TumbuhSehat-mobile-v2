import 'package:flutter/material.dart';
import '../../widgets/ts_page_scaffold.dart';

class EnterUniqueCodeScreen extends StatelessWidget {
  const EnterUniqueCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TSPageScaffold(
      appBar: AppBar(title: const Text('Masukkan Kode Unik')),
      body: const Center(
        child: Text('Halaman untuk memasukkan kode unik keluarga.'),
      ),
    );
  }
}
