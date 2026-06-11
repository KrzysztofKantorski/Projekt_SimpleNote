import "package:flutter/material.dart";
class DividerLabel extends StatelessWidget{

    final String label;
  final bool showLines;

  const DividerLabel({
    super.key,
    required this.label,
    this.showLines = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLines) {
      return Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF888888),
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
      ],
    );
  }
}