import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/parent_model.dart';
import '../../cubit/onboarding/onboarding_cubit.dart';
import '../../widgets/ts_button.dart';
import '../../widgets/ts_dropdown.dart';
import '../../widgets/ts_page_scaffold.dart';
import 'add_child_screen.dart';

class LactationCheckScreen extends StatefulWidget {
  const LactationCheckScreen({super.key});

  @override
  State<LactationCheckScreen> createState() => _LactationCheckScreenState();
}

class _LactationCheckScreenState extends State<LactationCheckScreen> {
  bool _isYesPressed = false;
  LactationPeriod? _selectedLactationPeriod;

  void _handleYesPressed() {
    setState(() {
      _isYesPressed = true;
    });
  }

  void _triggerSubmit(BuildContext context, {required bool isLactating}) {
    final cubit = context.read<OnboardingCubit>();
    if (isLactating) {
      if (_selectedLactationPeriod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih periode menyusui')),
        );
        return;
      }
      cubit.submitLactationStatus(
        isLactating: true,
        lactationPeriod: _selectedLactationPeriod,
      );
    } else {
      cubit.submitLactationStatus(isLactating: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is OnboardingFailure) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OnboardingSuccess) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AddChildScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        String parentFirstName = 'Ibu';
        if (state is OnboardingDataCollection && state.name != null) {
          parentFirstName = state.name!.split(' ').first;
        }

        return TSPageScaffold(
          appBar: AppBar(title: const Text('Kondisi Menyusui')),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apakah Ibu $parentFirstName sedang menyusui?',
                style: getResponsiveTextStyle(
                  context,
                  TSFont.bold.h2.withColor(TSColor.monochrome.black),
                ),
                textAlign: TextAlign.center,
              ),

              if (_isYesPressed) ...[
                const SizedBox(height: 48),
                const Text('Pilih periode menyusui:'),
                const SizedBox(height: 16),
                TSDropdown<LactationPeriod>(
                  label: 'Periode Menyusui',
                  value: _selectedLactationPeriod,
                  items: LactationPeriod.values
                      .where((p) => p != LactationPeriod.none)
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLactationPeriod = newValue;
                    });
                  },
                  itemBuilder: (period) {
                    String text;
                    switch (period) {
                      case LactationPeriod.oneToSixMonths:
                        text = '1 - 6 Bulan';
                        break;
                      case LactationPeriod.sevenToTwelveMonths:
                        text = '7 - 12 Bulan';
                        break;
                      case LactationPeriod.none:
                        text = 'Tidak Menyusui';
                        break;
                    }
                    return Text(text);
                  },
                  validator: (value) => value == null ? 'Pilih periode' : null,
                ),
              ],
              const SizedBox(height: 32),
              if (_isYesPressed)
                TSButton(
                  onPressed: () => _triggerSubmit(context, isLactating: true),
                  text: 'Selesai & Lanjutkan',
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
                onPressed: () => _triggerSubmit(context, isLactating: false),
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
