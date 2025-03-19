import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? btnText;
  final Color? backgroundColor;
  final double? elevation;
  final TextStyle? btnStyle;
  const CustomButton(
      {super.key,
      required this.btnText,
      this.backgroundColor,
      this.elevation = 0,
      this.btnStyle});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        '$btnText',
        style: btnStyle ?? const TextStyle(color: Colors.black),
      ),
    );
  }
}
