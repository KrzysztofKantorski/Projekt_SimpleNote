import '../models/comment/comment_model.dart';
import '../services/comment_service.dart';

abstract class CommentRepository {
  Future<List<CommentModel>> getComments(int noteId);
  Future<void> addComment({required int noteId, required String content});
  Future<void> deleteComment(int commentId, int noteId);
}

class CommentRepositoryImpl implements CommentRepository {
  final CommentService _commentService;

  const CommentRepositoryImpl({required CommentService commentService})
      : _commentService = commentService;

  @override
  Future<List<CommentModel>> getComments(int noteId) =>
      _commentService.getCommentsForNote(noteId);

  @override
  Future<void> addComment({required int noteId, required String content}) =>
      _commentService.addComment(noteId: noteId, content: content);

  @override
  Future<void> deleteComment(int commentId, int noteId) =>
      _commentService.deleteComment(commentId, noteId);
}
