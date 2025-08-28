import 'package:flutter/material.dart';

import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_text_style.dart';

class TSTextField extends StatefulWidget {
  final String placeholder;
  final Color backgroundColor;
  final Color borderColor;
  final Color placeholderColor = TSColor.monochrome.lightGrey;
  final bool isPassword;
  final double borderRadius;
  final double width;
  final List<BoxShadow> boxShadow;
  final TextEditingController controller;
  final List<String> validationMessageList;
  final List<bool Function(String)> validationLogicList;

  TSTextField({
    super.key,
    required this.placeholder,
    required this.backgroundColor,
    required this.borderColor,
    required this.isPassword,
    required this.borderRadius,
    required this.width,
    required this.boxShadow,
    required this.controller,
    required this.validationMessageList,
    required this.validationLogicList,
  }) : assert(
         validationLogicList.length == validationMessageList.length,
         "Jumlah validationLogic dan validationMessage harus sama",
       );

  @override
  TSTextFieldState createState() => TSTextFieldState();
}

class TSTextFieldState extends State<TSTextField> {
  bool _obscureText = false;
  String? _errorText;

  bool validate() {
    String text = widget.controller.text;
    for (int i = 0; i < widget.validationLogicList.length; i++) {
      bool isValid = widget.validationLogicList[i](text);
      if (!isValid) {
        setState(() {
          _errorText = widget.validationMessageList[i];
        });
        return false;
      }
    }
    setState(() {
      _errorText = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 2),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.boxShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
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
                    color: widget.placeholderColor,
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
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 8),
          child: Text(
            _errorText ?? " ",
            style: TSFont.bold.body.withColor(TSColor.additionalColor.red),
          ),
        ),
      ],
    );
  }
}
