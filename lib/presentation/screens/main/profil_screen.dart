import 'package:flutter/widgets.dart';

import '../../widgets/layouts/ts_page_scaffold.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return const TSPageScaffold(body: Center(child: Text('Profil Screen')));
  }
}