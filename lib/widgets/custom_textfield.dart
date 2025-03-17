import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final bool? filled;
  final Color? fillColor;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextfield({
    super.key,
    this.filled = true,
    this.obscureText = false,
    this.fillColor = Colors.white,
    required this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
          filled: filled,
          fillColor: fillColor,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.blue),
          )),
    );
  }
}
