import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/comment/comment_model.dart';

class CommentService {
  final Dio _dio = DioClient().dio;

  // === POBIERANIE KOMENTARZY DLA NOTATKI (GET) ===
  Future<List<CommentModel>> getCommentsForNote(int noteId) async {
    try {
      final response = await _dio.get('/api/notes/$noteId/comments');
      
      final List<dynamic> rawData = response.data;
      return CommentModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // === DODAWANIE NOWEGO KOMENTARZA (POST) ===
  Future<void> addComment({
    required int noteId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'Content': content,
        if (parentCommentId != null) 'ParentCommentId': parentCommentId,
      };

      await _dio.post(
        '/api/notes/$noteId/comments',
        data: body,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // === USUWANIE KOMENTARZA (DELETE) ===
  // Dostosowane do Twojej trasy z backendu: /api/notes/{noteId}/comments/{commentId}
  Future<void> deleteComment(int commentId, int noteId) async {
    try {
      await _dio.delete('/api/notes/$noteId/comments/$commentId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // === DEKODOWANIE BŁĘDÓW (Zgodne z Twoim szablonem) ===
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data == null) return 'Błąd komunikacji z serwerem (Kod: ${e.response?.statusCode})';
    if (data is String) return data.trim().isNotEmpty ? data : 'Wystąpił błąd';
    
    if (data is List) {
      if (data.isNotEmpty && data.first is Map && data.first.containsKey('description')) {
        return data.first['description'].toString();
      }
      return 'Błąd serwera (Lista)';
    }

    if (data is Map) {
      if (data.containsKey('message') && data['message'] != null) return data['message'].toString();
      if (data.containsKey('title') && data['title'] != null) return data['title'].toString();
    }
    return 'Wystąpił błąd serwera (Kod: ${e.response?.statusCode})';
  }
}