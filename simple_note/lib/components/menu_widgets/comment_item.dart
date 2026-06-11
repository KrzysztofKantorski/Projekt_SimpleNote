// import 'package:flutter/material.dart';
// import '../../model/note_model.dart';

// /// Pojedynczy komentarz — avatar + nazwa użytkownika + treść
// class SnCommentItem extends StatelessWidget {
//   final CommentModel comment;

//   const SnCommentItem({super.key, required this.comment});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFF222222),
//               image: comment.authorAvatarUrl != null
//                   ? DecorationImage(
//                       image: NetworkImage(comment.authorAvatarUrl!),
//                       fit: BoxFit.cover)
//                   : null,
//             ),
//             child: comment.authorAvatarUrl == null
//                 ? const Icon(Icons.person, size: 18, color: Colors.white)
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           // Treść
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   comment.authorName,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   comment.text,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF666666),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
