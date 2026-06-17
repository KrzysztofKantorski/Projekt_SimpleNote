import 'package:flutter/material.dart';

/// Pojedynczy wiersz notatki na liście
class SnNoteListItem extends StatelessWidget {
  final String title;
  final String content;
  final String timeAgo;
  final VoidCallback? onTap;      // Kliknięcie w całą kartę (np. podgląd)
  final VoidCallback? onEditClick; // Kliknięcie w ikonkę ołówka (edycja)

  const SnNoteListItem({
    super.key,
    required this.title,
    required this.content,
    required this.timeAgo,
    this.onTap,
    this.onEditClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CircleAvatar(radius: 3, backgroundColor: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Tytuł + Opis
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '"$title"',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '  $timeAgo',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEditClick,
              icon: const Icon(
                Icons.edit_outlined,
                size: 20, 
                color: Color(0xFF666666),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}