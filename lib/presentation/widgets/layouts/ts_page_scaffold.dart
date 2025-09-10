import 'package:flutter/material.dart';

import 'ts_app_bar.dart';

class TSPageScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBackButtonPressed;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const TSPageScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.onBackButtonPressed,
    this.showBackButton = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    final double horizontalPadding = isTablet ? 60.0 : 32.0;

    void unfocusKeyboard() {
      FocusScope.of(context).unfocus();
    }

    return GestureDetector(
      onTap: unfocusKeyboard,
      child: Scaffold(
        appBar: title != null
            ? TSAppBar(
                title: title!,
                actions: actions,
                onBackButtonPressed: onBackButtonPressed,
                showBackButton: showBackButton,
              )
            : null,
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
