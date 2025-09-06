import 'package:flutter/widgets.dart';

import '../widgets/ts_page_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(
      body: Center(child: Text('Selamat Datang di Beranda!')),
    );
  }
}
