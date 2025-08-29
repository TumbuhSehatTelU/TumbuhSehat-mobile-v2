// ignore_for_file: use_super_parameters

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_text_style.dart';

class GenericLoadingModalContent extends StatefulWidget {
  final String lottieAnimation;
  final String message;

  const GenericLoadingModalContent({
    Key? key,
    required this.lottieAnimation,
    required this.message,
  }) : super(key: key);

  @override
  State<GenericLoadingModalContent> createState() =>
      _GenericLoadingModalContentState();
}

class _GenericLoadingModalContentState
    extends State<GenericLoadingModalContent> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          widget.lottieAnimation,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),

        Text(
          '${widget.message}$dots',
          textAlign: TextAlign.center,
          style: TSFont.semiBold.large.withColor(TSColor.monochrome.black),
        ),
      ],
    );
  }
}
