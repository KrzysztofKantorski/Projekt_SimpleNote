import 'package:flutter/material.dart';

/// Pasek "Add a comment" na dole ekranu podglądu notatki
class SnAddCommentBar extends StatelessWidget {
  final VoidCallback? onTap;

  const SnAddCommentBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF888888)),
            SizedBox(width: 8),
            Text(
              'Add a comment',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}
