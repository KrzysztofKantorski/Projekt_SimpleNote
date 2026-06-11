import 'package:flutter/material.dart';

/// Pasek narzędzi formatowania nad klawiaturą (Aa, lista, Bold, liczba słów, checkbox, kolor)
class SnEditorToolbar extends StatelessWidget {
  final VoidCallback? onFontSize;
  final VoidCallback? onBulletList;
  final VoidCallback? onBold;
  final VoidCallback? onCheckbox;
  final VoidCallback? onColorPicker;
  final int wordCount;

  const SnEditorToolbar({
    super.key,
    this.onFontSize,
    this.onBulletList,
    this.onBold,
    this.onCheckbox,
    this.onColorPicker,
    this.wordCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        border: Border(
          top: BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          _ToolbarButton(
            label: 'Aa',
            isText: true,
            onTap: onFontSize,
          ),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            onTap: onBulletList,
          ),
          _ToolbarButton(
            label: 'B',
            isText: true,
            bold: true,
            onTap: onBold,
          ),
          // Licznik słów
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$wordCount',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _ToolbarButton(
            icon: Icons.check_box_outlined,
            onTap: onCheckbox,
          ),
          // Kółko koloru (czarne wypełnienie)
          GestureDetector(
            onTap: onColorPicker,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isText;
  final bool bold;
  final VoidCallback? onTap;

  const _ToolbarButton({
    this.label,
    this.icon,
    this.isText = false,
    this.bold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: icon != null
            ? Icon(icon, size: 20, color: const Color(0xFF444444))
            : Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF444444),
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
