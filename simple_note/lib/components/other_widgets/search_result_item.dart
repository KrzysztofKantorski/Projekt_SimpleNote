import 'package:flutter/material.dart';
import 'package:simple_note/models/note/note_model.dart';

/// Wynik wyszukiwania — wiersz z avatarem, tytułem i opisem notatki
class SnSearchResultItem extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;

  const SnSearchResultItem({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar autora
            // Container(
            //   width: 42,
            //   height: 42,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: const Color(0xFF222222),
            //     image: note.authorAvatarUrl != null
            //         ? DecorationImage(
            //             image: NetworkImage(note.authorAvatarUrl!),
            //             fit: BoxFit.cover)
            //         : null,
            //   ),
            //   child: note.authorAvatarUrl == null
            //       ? const Icon(Icons.person, size: 20, color: Colors.white)
            //       : null,
            // ),
            const SizedBox(width: 14),
            // Tytuł + opis
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
