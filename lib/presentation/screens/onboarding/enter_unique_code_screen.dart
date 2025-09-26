import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../cubit/onboarding/onboarding_cubit.dart';
import '../../widgets/onboarding/ts_auth_header.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../../widgets/common/ts_text_field.dart';
import 'parent_registration_screen.dart';

class EnterUniqueCodeScreen extends StatefulWidget {
  const EnterUniqueCodeScreen({super.key});

  @override
  State<EnterUniqueCodeScreen> createState() => _EnterUniqueCodeScreenState();
}

class _EnterUniqueCodeScreenState extends State<EnterUniqueCodeScreen> {
  late final TextEditingController _codeController;
  final _formKey = GlobalKey<FormState>();

  int _failureCount = 0;
  DateTime? _penaltyReleaseTime;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  static const String _failureCountKey = 'unique_code_failure_count';
  static const String _penaltyReleaseKey = 'unique_code_penalty_release_time';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _loadPenaltyState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPenaltyState() async {
    final prefs = await SharedPreferences.getInstance();
    _failureCount = prefs.getInt(_failureCountKey) ?? 0;
    final releaseTimestamp = prefs.getInt(_penaltyReleaseKey);

    if (releaseTimestamp != null) {
      _penaltyReleaseTime = DateTime.fromMillisecondsSinceEpoch(
        releaseTimestamp,
      );
      if (_penaltyReleaseTime!.isAfter(DateTime.now())) {
        _secondsRemaining = _penaltyReleaseTime!
            .difference(DateTime.now())
            .inSeconds;
        _startCountdown();
      }
    }
    setState(() {});
  }

  Future<void> _savePenaltyState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_failureCountKey, _failureCount);
    if (_penaltyReleaseTime != null) {
      await prefs.setInt(
        _penaltyReleaseKey,
        _penaltyReleaseTime!.millisecondsSinceEpoch,
      );
    }
  }

  void _handleFailure() {
    setState(() {
      _failureCount++;
    });
    _savePenaltyState();

    if (_failureCount > 0 && _failureCount % 5 == 0) {
      _startPenaltyTimer();
    }
  }

  void _startPenaltyTimer() {
    final penaltyTier = (_failureCount / 5).floor() - 1;
    final baseMinutes = 30;
    final penaltyMinutes = baseMinutes * pow(2, penaltyTier);

    _penaltyReleaseTime = DateTime.now().add(
      Duration(minutes: penaltyMinutes.toInt()),
    );
    _savePenaltyState();
    setState(() {
      _secondsRemaining = penaltyMinutes.toInt() * 60;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {});
      }
    });
  }

  void _handleSubmit(BuildContext context, bool isLoading) {
    if (isLoading || _secondsRemaining > 0) return;

    if (_formKey.currentState?.validate() ?? false) {
      context.read<OnboardingCubit>().checkUniqueCode(
        _codeController.text.trim(),
      );
    }
  }

  String get _attemptsText {
    if (_failureCount == 0) return '';
    final attemptsLeft = 5 - (_failureCount % 5);
    return 'Kesempatan tersisa: $attemptsLeft';
  }

  String get _penaltyTimeText {
    final duration = Duration(seconds: _secondsRemaining);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return 'Terlalu banyak percobaan. Coba lagi dalam $minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingFailure) {
          _handleFailure();
        } else if (state is OnboardingDataCollection) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const ParentRegistrationScreen(isJoiningFamily: true),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OnboardingLoading;
        final isPenalized = _secondsRemaining > 0;

        return TSPageScaffold(
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(),
                Spacer(flex: 1),
                Text(
                  "Masukkan Kode Unik\nKeluarga Anda",
                  style: TSFont.getStyle(
                    context,
                    TSFont.bold.h2.withColor(TSColor.monochrome.black),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Gunakan Kode Unik dari keluarga anda\nagar saling terhubung",
                  style: TSFont.getStyle(
                    context,
                    TSFont.regular.large.withColor(TSColor.monochrome.black),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Tidak tahu cara melihat kode unik? klik di sini",
                  style: TSFont.getStyle(
                    context,
                    TSFont.regular.body.withColor(TSColor.monochrome.black),
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(flex: 1),
                Text(
                  "Kode Unik",
                  style: TSFont.getStyle(
                    context,
                    TSFont.bold.large.withColor(TSColor.monochrome.black),
                  ),
                ),
                const SizedBox(height: 16),
                TSTextField(
                  placeholder: 'Contoh: 1356ABCD',
                  controller: _codeController,
                  isPassword: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode tidak boleh kosong';
                    }
                    return null;
                  },
                  backgroundColor: TSColor.monochrome.pureWhite,
                  borderColor: Colors.transparent,
                  borderRadius: 240,
                  width: double.infinity,
                  boxShadow: TSShadow.shadows.weight500,
                ),
                const SizedBox(height: 8),
                if (isPenalized)
                  Text(
                    _penaltyTimeText,
                    style: TextStyle(color: TSColor.additionalColor.red),
                  )
                else
                  Text(_attemptsText),

                const SizedBox(height: 24),

                TSButton(
                  onPressed: () => _handleSubmit(context, isLoading),
                  text: isLoading ? 'Memeriksa...' : 'Lanjutkan',
                  textStyle: TSFont.getStyle(context, TSFont.bold.large),
                  backgroundColor: (isLoading || isPenalized)
                      ? TSColor.monochrome.grey
                      : TSColor.secondaryGreen.primary,
                  borderColor: Colors.transparent,
                  contentColor: TSColor.monochrome.black,
                  customBorderRadius: 240,
                ),
                Spacer(flex: 3),
              ],
            ),
          ),
        );
      },
    );
  }
}
