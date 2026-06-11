import 'package:flutter/material.dart';
import '../../models/note/note_model.dart';

/// Pojedynczy wiersz notatki na liście (ekran główny)
class SnNoteListItem extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const SnNoteListItem({
    super.key,
    required this.note,
    this.onTap,
    this.onDownload,
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
            // Bullet
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
            // Thumbnail
            // Container(
            //   width: 48,
            //   height: 48,
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF0F0F0),
            //     borderRadius: BorderRadius.circular(4),
            //     image: note.thumbnailUrl != null
            //         ? DecorationImage(
            //             image: NetworkImage(note.thumbnailUrl!),
            //             fit: BoxFit.cover)
            //         : null,
            //   ),
            //   child: note.thumbnailUrl == null
            //       ? const Icon(Icons.article_outlined,
            //           size: 24, color: Color(0xFFAAAAAA))
            //       : null,
            // ),
            const SizedBox(width: 12),
            // Tytuł + opis
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '"${note.title}"',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '  ${note.timeAgo}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF888888),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.content,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Ikona pobierania
            IconButton(
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined,
                  size: 20, color: Color(0xFF666666)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
