import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/comment/comment_model.dart';

class CommentService {
  final Dio _dio;

  const CommentService({required Dio dio}) : _dio = dio;

  Future<List<CommentModel>> getCommentsForNote(int noteId) async {
    try {
      final response = await _dio.get('/api/notes/$noteId/comments');
      final List<dynamic> raw = response.data;
      return CommentModel.fromJsonList(raw);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> addComment({
    required int noteId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      await _dio.post('/api/notes/$noteId/comments', data: {
        'Content': content,
        if (parentCommentId != null) 'ParentCommentId': parentCommentId,
      });
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> deleteComment(int commentId, int noteId) async {
    try {
      await _dio.delete('/api/notes/$noteId/comments/$commentId');
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
}