// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_text_style.dart';
import '../../gen/assets.gen.dart';
import '../cubit/splash/splash_cubit.dart';
import '../widgets/onboarding/ts_auth_header.dart';
import '../widgets/common/ts_button.dart';
import '../widgets/layouts/ts_page_scaffold.dart';
import 'main/main_screen.dart';
// import 'onboarding/join_or_create_screen.dart';
import 'onboarding/parent_registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  // TODO: nanti di ganti ke JoinOrCreateScreen, setelah demo posyandu selesai
  Widget _destinationScreen = const ParentRegistrationScreen(
    isJoiningFamily: false,
  );

  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().checkAuthStatus();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _timer = Timer(const Duration(seconds: 5), _navigate);
  }

  void _navigate() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _destinationScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated) {
          setState(() {
            _destinationScreen = const MainScreen();
          });
        } else if (state is SplashUnauthenticated) {
          setState(() {
            _destinationScreen = const ParentRegistrationScreen(
              isJoiningFamily: false,
            );
          });
        }
      },

      child: TSPageScaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(),
              const Spacer(),
              Text(
                "Bantu Ibu Pantau Gizi,\n Jaga Tumbuh\n Kembang Anak!",
                style: TSFont.getStyle(
                  context,
                  TSFont.bold.h1.withColor(TSColor.monochrome.black),
                ),
              ),
              const Spacer(flex: 2),
              _buildBottomBar(),
              const Spacer(),
              Assets.images.illustrationSplashScreen.svg(
                width: maxWidth * 0.9,
                height: maxHeight * (isTablet ? 0.3 : 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0).copyWith(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TSButton(
            onPressed: _navigate,
            text: 'Mulai Sekarang',
            textStyle: TSFont.getStyle(context, TSFont.bold.large),
            backgroundColor: TSColor.secondaryGreen.primary,
            borderColor: Colors.transparent,
            contentColor: TSColor.monochrome.black,
            customBorderRadius: 48,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  value: _controller.value,
                  backgroundColor: TSColor.monochrome.lightGrey.withOpacity(
                    0.3,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    TSColor.secondaryGreen.shade400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
