import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? btnText;
  final Color? backgroundColor;
  final double? elevation;
  final double borderRadius;
  final TextStyle? btnStyle;
  final void Function()? onPressed;
  const CustomButton(
      {super.key,
      required this.btnText,
      this.backgroundColor,
      this.elevation = 0,
      this.borderRadius = 4,
      this.btnStyle,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        '$btnText',
        style: btnStyle ?? const TextStyle(color: Colors.black),
      ),
    );
  }
}
