import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/parent_model.dart';
import '../../cubit/onboarding/onboarding_cubit.dart';
import '../../widgets/ts_button.dart';
import '../../widgets/ts_dropdown.dart';
import '../../widgets/ts_page_scaffold.dart';
import 'lactation_check_screen.dart';

class PregnancyCheckScreen extends StatefulWidget {
  const PregnancyCheckScreen({super.key});

  @override
  State<PregnancyCheckScreen> createState() => _PregnancyCheckScreenState();
}

class _PregnancyCheckScreenState extends State<PregnancyCheckScreen> {
  bool _isYesPressed = false;
  GestationalAge? _selectedGestationalAge;

  void _handleYesPressed() {
    setState(() {
      _isYesPressed = true;
    });
  }

  void _handleNoPressed(BuildContext context) {
    context.read<OnboardingCubit>().submitPregnancyStatus(isPregnant: false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LactationCheckScreen()),
    );
  }

  void _handleContinuePressed(BuildContext context) {
    if (_selectedGestationalAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih usia kehamilan')),
      );
      return;
    }
    context.read<OnboardingCubit>().submitPregnancyStatus(
      isPregnant: true,
      gestationalAge: _selectedGestationalAge,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LactationCheckScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        String parentFirstName = 'Ibu';
        if (state is OnboardingDataCollection && state.name != null) {
          parentFirstName = state.name!.split(' ').first;
        }

        return TSPageScaffold(
          title: 'Kondisi Kehamilan',
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apakah Ibu $parentFirstName sedang hamil?',
                style: getResponsiveTextStyle(
                  context,
                  TSFont.bold.h2.withColor(TSColor.monochrome.black),
                ),
                textAlign: TextAlign.center,
              ),

              if (_isYesPressed) ...[
                const SizedBox(height: 48),
                Text(
                  'Pilih usia kehamilan:',
                  style: getResponsiveTextStyle(context, TSFont.bold.body),
                ),
                const SizedBox(height: 16),
                TSDropdown<GestationalAge>(
                  label: 'Usia Kehamilan',
                  value: _selectedGestationalAge,
                  items: GestationalAge.values
                      .where((age) => age != GestationalAge.none)
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGestationalAge = newValue;
                    });
                  },
                  itemBuilder: (age) {
                    String text;
                    switch (age) {
                      case GestationalAge.month1:
                        text = 'Bulan 1 (0-4 Minggu)';
                        break;
                      case GestationalAge.month2:
                        text = 'Bulan 2 (5-8 Minggu)';
                        break;
                      case GestationalAge.month3:
                        text = 'Bulan 3 (9-13 Minggu)';
                        break;
                      case GestationalAge.month4:
                        text = 'Bulan 4 (14-17 Minggu)';
                        break;
                      case GestationalAge.month5:
                        text = 'Bulan 5 (18-22 Minggu)';
                        break;
                      case GestationalAge.month6:
                        text = 'Bulan 6 (23-27 Minggu)';
                        break;
                      case GestationalAge.month7:
                        text = 'Bulan 7 (28-31 Minggu)';
                        break;
                      case GestationalAge.month8:
                        text = 'Bulan 8 (32-35 Minggu)';
                        break;
                      case GestationalAge.month9:
                        text = 'Bulan 9 (36-40 Minggu)';
                        break;
                      case GestationalAge.none:
                        text = 'Tidak Hamil';
                        break;
                    }
                    return Text(text);
                  },
                  boxShadow: TSShadow.shadows.weight500,
                  validator: (value) => value == null ? 'Pilih usia' : null,
                ),
              ],
              const SizedBox(height: 32),
              if (_isYesPressed)
                TSButton(
                  onPressed: () => _handleContinuePressed(context),
                  text: 'Lanjutkan',
                  textStyle: getResponsiveTextStyle(
                    context,
                    TSFont.extraBold.h3,
                  ),
                  backgroundColor: TSColor.mainTosca.shade400,
                  borderColor: Colors.transparent,
                  contentColor: TSColor.monochrome.white,
                  customBorderRadius: 240,
                )
              else
                TSButton(
                  onPressed: _handleYesPressed,
                  text: 'Ya',
                  textStyle: getResponsiveTextStyle(
                    context,
                    TSFont.extraBold.h3,
                  ),
                  backgroundColor: TSColor.mainTosca.shade400,
                  borderColor: Colors.transparent,
                  contentColor: TSColor.monochrome.white,
                  customBorderRadius: 240,
                ),

              const SizedBox(height: 16),

              TSButton(
                onPressed: () => _handleNoPressed(context),
                text: 'Tidak',
                textStyle: getResponsiveTextStyle(context, TSFont.extraBold.h3),
                backgroundColor: TSColor.monochrome.white,
                borderColor: TSColor.mainTosca.shade400,
                contentColor: TSColor.mainTosca.shade400,
                borderWidth: 4,
                customBorderRadius: 240,
              ),
            ],
          ),
        );
      },
    );
  }
}
