import 'package:flutter/material.dart';

import '../../widgets/ts_page_scaffold.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(
      body: Center(child: Text('Halaman untuk menambah data anak')),
    );
  }
}
