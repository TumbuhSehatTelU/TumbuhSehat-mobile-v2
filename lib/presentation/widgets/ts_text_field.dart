// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_text_style.dart';

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
    required String placeholder,
    required Color backgroundColor,
    required Color borderColor,
    required bool isPassword,
    required double borderRadius,
    required double width,
    required List<BoxShadow> boxShadow,
    FormFieldValidator<String>? validator, // Menggunakan validator standar
  }) : super(
         validator: validator,
         initialValue: controller?.text,
         builder: (FormFieldState<String> field) {
           // Widget _InnerTSTextField ini akan mengelola state UI lokal (seperti show/hide password)
           // sementara FormFieldState (field) mengelola state data (value, error).
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
           );
         },
       );
}

class _InnerTSTextField extends StatefulWidget {
  final FormFieldState<String> field;
  final TextEditingController? controller;
  final String placeholder;
  final Color backgroundColor;
  final Color borderColor;
  final bool isPassword;
  final double borderRadius;
  final double width;
  final List<BoxShadow> boxShadow;

  const _InnerTSTextField({
    required this.field,
    this.controller,
    required this.placeholder,
    required this.backgroundColor,
    required this.borderColor,
    required this.isPassword,
    required this.borderRadius,
    required this.width,
    required this.boxShadow,
  });

  @override
  _InnerTSTextFieldState createState() => _InnerTSTextFieldState();
}

class _InnerTSTextFieldState extends State<_InnerTSTextField> {
  bool _obscureText = false;
  late final TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveController =
        widget.controller ?? TextEditingController(text: widget.field.value);

    _effectiveController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
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
                  : widget.borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.boxShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
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
  }
}
