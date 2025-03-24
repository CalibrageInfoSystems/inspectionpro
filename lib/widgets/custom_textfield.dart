import 'package:flutter/material.dart';
import 'package:inspectionpro/utils/styles.dart';

class CustomTextfield extends StatelessWidget {
  final bool? filled;
  final Color? fillColor;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final Color? focusBorderColor;
  final int? maxLines;
  final int? maxLength;

  const CustomTextfield({
    super.key,
    this.filled = true,
    this.obscureText = false,
    this.fillColor = Colors.white,
    this.focusBorderColor,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      focusNode: focusNode,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      style: CommonStyles.txStyF15CbFF5,
      decoration: InputDecoration(
          filled: filled,
          counterText: '',
          fillColor: fillColor,
          hintText: hintText,
          hintStyle: const TextStyle(color: CommonStyles.colorGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: CommonStyles.colorGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: CommonStyles.colorGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: focusBorderColor ?? Colors.blue),
          )),
    );
  }
}
