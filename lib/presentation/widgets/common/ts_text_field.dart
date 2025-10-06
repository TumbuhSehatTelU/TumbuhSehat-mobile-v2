// ignore_for_file: non_constant_identifier_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';

FormFieldValidator<String> TSValidator(
  List<bool Function(String)> logicList,
  List<String> messageList,
) {
  return (value) {
    final text = value ?? '';
    for (int i = 0; i < logicList.length; i++) {
      if (!logicList[i](text)) {
        return messageList[i];
      }
    }
    return null;
  };
}

class TSTextField extends FormField<String> {
  final TextEditingController? controller;

  TSTextField({
    super.key,
    this.controller,
    String? placeholder,
    required Color backgroundColor,
    Color borderColor = Colors.transparent,
    required bool isPassword,
    double borderRadius = 240,
    double width = double.infinity,
    required List<BoxShadow> boxShadow,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
  }) : super(
         validator: validator,
         initialValue: controller?.text,
         builder: (FormFieldState<String> field) {
           return _InnerTSTextField(
             field: field,
             controller: controller,
             placeholder: placeholder,
             backgroundColor: backgroundColor,
             borderColor: borderColor,
             isPassword: isPassword,
             borderRadius: borderRadius,
             width: width,
             boxShadow: boxShadow,
             keyboardType: keyboardType,
             textInputAction: textInputAction,
             inputFormatters: inputFormatters,
           );
         },
       );
}

class _InnerTSTextField extends StatefulWidget {
  final FormFieldState<String> field;
  final TextEditingController? controller;
  final String? placeholder;
  final Color backgroundColor;
  final Color borderColor;
  final bool isPassword;
  final double borderRadius;
  final double width;
  final List<BoxShadow> boxShadow;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const _InnerTSTextField({
    required this.field,
    this.controller,
    this.placeholder,
    required this.backgroundColor,
    this.borderColor = Colors.transparent,
    required this.isPassword,
    this.borderRadius = 240,
    this.width = double.infinity,
    required this.boxShadow,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  @override
  _InnerTSTextFieldState createState() => _InnerTSTextFieldState();
}

class _InnerTSTextFieldState extends State<_InnerTSTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = false;
  late final TextEditingController _effectiveController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveController =
        widget.controller ?? TextEditingController(text: widget.field.value);
    _effectiveController.addListener(_onControllerChanged);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _borderColorAnimation = ColorTween(
      begin: widget.borderColor,
      end: TSColor.secondaryGreen.primary,
    ).animate(_animationController);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.field.value != _effectiveController.text) {
      widget.field.didChange(_effectiveController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.field.hasError;
    final errorText = widget.field.errorText;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: Border.all(
                  color: hasError
                      ? TSColor.additionalColor.red
                      : (_focusNode.hasFocus
                            ? _borderColorAnimation.value!
                            : widget.borderColor),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.boxShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      inputFormatters: widget.inputFormatters,
                      keyboardType: widget.keyboardType,
                      textInputAction:
                          widget.textInputAction ?? TextInputAction.next,
                      controller: _effectiveController,
                      obscureText: _obscureText,
                      style: TSFont.regular.body.withColor(
                        TSColor.monochrome.black,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TSFont.regular.body.withColor(
                          TSColor.monochrome.lightGrey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (widget.isPassword)
                    IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: TSColor.monochrome.lightGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                ],
              ),
            ),
            if (hasError && errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  errorText,
                  style: TSFont.regular.small.withColor(
                    TSColor.additionalColor.red,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
