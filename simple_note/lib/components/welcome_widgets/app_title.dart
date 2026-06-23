import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'SimpleNote',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }
}