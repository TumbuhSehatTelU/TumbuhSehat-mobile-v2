import 'package:flutter/material.dart';


import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/ts_auth_header.dart';
import '../../widgets/ts_button.dart';
import '../../widgets/ts_page_scaffold.dart';
import 'enter_unique_code_screen.dart';
import 'parent_registration_screen.dart';

class JoinOrCreateScreen extends StatefulWidget {
  const JoinOrCreateScreen({super.key});

  @override
  State<JoinOrCreateScreen> createState() => _JoinOrCreateScreenState();
}

class _JoinOrCreateScreenState extends State<JoinOrCreateScreen> {
  void _onJoinFamilyPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnterUniqueCodeScreen()),
    );
  }

  void _onCreateFamilyPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const ParentRegistrationScreen(isJoiningFamily: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return TSPageScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AuthHeader(),
          Spacer(flex: 1),
          Text(
            "Apakah anggota keluarga Anda\nsudah ada yang menggunakan\nTumbuhSehat?",
            style: getResponsiveTextStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.black),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
          TSButton(
            onPressed: () => _onJoinFamilyPressed(context),
            text: 'Ya, Sudah Ada',
            textStyle: getResponsiveTextStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.pureWhite),
            ),
            backgroundColor: TSColor.additionalColor.green,
            borderColor: Colors.transparent,
            contentColor: Colors.white,
            customBorderRadius: 248,
            size: ButtonSize.medium,
            boxShadow: TSShadow.shadows.weight300,
          ),
          const SizedBox(height: 16),
          TSButton(
            onPressed: () => _onCreateFamilyPressed(context),
            text: 'Tidak ada',
            textStyle: getResponsiveTextStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.additionalColor.red),
            ),
            backgroundColor: TSColor.monochrome.white,
            borderColor: TSColor.additionalColor.red,
            contentColor: TSColor.additionalColor.red,
            customBorderRadius: 248,
            size: ButtonSize.medium,
            borderWidth: 4,
            boxShadow: TSShadow.elevations.weight300,
          ),
          const Spacer(flex: 1),
          Assets.images.illustrationYesOrNo.svg(
            width: maxWidth * 0.9,
            height: maxHeight * 0.25,
          ),
        ],
      ),
    );
  }
}
