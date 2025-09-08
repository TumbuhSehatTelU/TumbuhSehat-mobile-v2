import 'package:flutter/widgets.dart';

import '../../widgets/ts_page_scaffold.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(
      body: Center(child: Text('Selamat Datang di Beranda!')),
    );
  }
}
