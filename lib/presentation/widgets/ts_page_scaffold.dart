import 'package:flutter/material.dart';

class TSPageScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const TSPageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    final double horizontalPadding = isTablet ? 60.0 : 24.0;

    void unfocusKeyboard() {
      FocusScope.of(context).unfocus();
    }

    return GestureDetector(
      onTap: unfocusKeyboard,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: body,
          ),
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
