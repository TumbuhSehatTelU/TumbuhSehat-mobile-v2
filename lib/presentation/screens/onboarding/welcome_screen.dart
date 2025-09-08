// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../widgets/ts_page_scaffold.dart';
import '../main/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 500000),
    )..forward();

    _timer = Timer(const Duration(seconds: 500000), _navigateToHome);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToHome() {
    _timer?.cancel();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToHome,
      child: TSPageScaffold(
        body: const Center(
          child: Text(
            'Selamat Datang!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBar: _buildProgressBar(),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: TSColor.monochrome.lightGrey.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              TSColor.mainTosca.primary,
            ),
          );
        },
      ),
    );
  }
}
