import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../gen/assets.gen.dart';
import 'beranda_screen.dart';
import 'chatbot_screen.dart';
import 'komunitas_screen.dart';
import 'profil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeIndex = 0;

  final List<Widget> _pages = const [
    BerandaScreen(),
    ChatbotScreen(),
    KomunitasScreen(),
    ProfilScreen(),
  ];

  final List<String> _iconNames = ['Beranda', 'Chatbot', 'Komunitas', 'Profil'];

  void _onScanPressed() {
    // TODO: Implement navigation or action for Scan button
    print('Scan button pressed!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_activeIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onScanPressed,
        backgroundColor: TSColor.mainTosca.primary,
        child: SvgPicture.asset(
          Assets.icons.scan.path,
          colorFilter: ColorFilter.mode(
            TSColor.monochrome.pureWhite,
            BlendMode.srcIn,
          ),
          width: 24,
          height: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _pages.length,
        tabBuilder: (int index, bool isActive) {
          final iconName = _iconNames[index];
          final color = isActive
              ? TSColor.mainTosca.primary
              : TSColor.monochrome.black;
          final style = isActive ? TSFont.bold.small : TSFont.regular.small;
          final assetPath = isActive
              ? 'assets/icons/$iconName Active.svg'
              : 'assets/icons/$iconName Inactive.svg';

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(iconName, style: style.withColor(color)),
            ],
          );
        },
        activeIndex: _activeIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _activeIndex = index),
      ),
    );
  }
}
