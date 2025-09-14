import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyConsumptionDetailScreen extends StatefulWidget {
  final dynamic member;
  final DateTime date;

  const DailyConsumptionDetailScreen({
    super.key,
    required this.member,
    required this.date,
  });

  @override
  State<DailyConsumptionDetailScreen> createState() =>
      _DailyConsumptionDetailScreenState();
}

class _DailyConsumptionDetailScreenState
    extends State<DailyConsumptionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(widget.date);

    return Scaffold(
      appBar: AppBar(title: Text('Detail Konsumsi ${widget.member.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Menampilkan detail untuk tanggal:'),
            Text(
              dateFormatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
