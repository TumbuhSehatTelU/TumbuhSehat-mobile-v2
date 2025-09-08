import 'package:flutter/widgets.dart';

import '../../widgets/ts_page_scaffold.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(body: Center(child: Text('Komunitas Screen')));
  }
}
