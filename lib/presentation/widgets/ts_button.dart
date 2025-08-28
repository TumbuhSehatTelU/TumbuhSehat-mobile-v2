import 'package:flutter/material.dart';

enum ButtonSize { large, medium, small }

enum ButtonStyleType { leftIcon, rightIcon, textOnly, iconOnly }

// Contoh penggunaan

// TSButton(
//   onPressed: () {},
//   text: 'Kustom Lebar',
//   backgroundColor: Colors.green,
//   borderColor: Colors.black,
//   contentColor: Colors.white,
//   size: ButtonSize.medium,
//   style: ButtonStyleType.textOnly,
//   textStyle: Regular.h1,
//   width: 200,
// )

class TSButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final IconData? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color contentColor;
  final ButtonSize size;
  final ButtonStyleType style;
  final double? customBorderRadius;
  final TextStyle? textStyle;
  final double? width;
  final List<BoxShadow>? boxShadow;
  final double? borderWidth;

  const TSButton({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.contentColor,
    this.textStyle,
    this.size = ButtonSize.medium,
    this.style = ButtonStyleType.textOnly,
    this.customBorderRadius,
    this.width,
    this.boxShadow,
    this.borderWidth,
  });

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
      case ButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 6, horizontal: 12);
    }
  }

  double get _defaultRadius {
    switch (size) {
      case ButtonSize.large:
        return 12;
      case ButtonSize.medium:
        return 8;
      case ButtonSize.small:
        return 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      customBorderRadius ?? _defaultRadius,
    );

    Widget content;

    switch (style) {
      case ButtonStyleType.leftIcon:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: contentColor),
            const SizedBox(width: 8),
            if (text != null)
              Text(text!, style: textStyle?.copyWith(color: contentColor)),
          ],
        );
        break;
      case ButtonStyleType.rightIcon:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (text != null)
              Text(text!, style: textStyle?.copyWith(color: contentColor)),
            const SizedBox(width: 8),
            if (icon != null) Icon(icon, color: contentColor),
          ],
        );
        break;
      case ButtonStyleType.textOnly:
        content = Text(
          text ?? '',
          style: textStyle?.copyWith(color: contentColor),
        );
        break;
      case ButtonStyleType.iconOnly:
        content = Icon(icon, color: contentColor);
        break;
    }

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          border: Border.all(color: borderColor, width: borderWidth ?? 2.0),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: _padding,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
