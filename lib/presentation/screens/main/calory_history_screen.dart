import 'package:flutter/material.dart';

class CaloryHistoryScreen extends StatefulWidget {
  final String memberName;

  const CaloryHistoryScreen({super.key, required this.memberName});

  @override
  State<CaloryHistoryScreen> createState() => _CaloryHistoryScreenState();
}

class _CaloryHistoryScreenState extends State<CaloryHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Kalori ${widget.memberName}')),
      body: Center(
        child: Text('Ini halaman riwayat kalori untuk ${widget.memberName}'),
      ),
    );
  }
}
