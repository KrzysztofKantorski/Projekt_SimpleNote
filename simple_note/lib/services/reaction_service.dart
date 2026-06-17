import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/reaction/reaction_model.dart';

class ReactionService {
  final Dio _dio = DioClient().dio;

  Future<List<ReactionTypeModel>> getAvailableReactions() async {
    try {
      final response = await _dio.get('/api/reaction-types');
      final List<dynamic> rawData = response.data;
      return ReactionTypeModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<NoteReactionModel>> getNoteReactionsSummary(int noteId) async {
    try {
      final response = await _dio.get('/api/notes/$noteId/reactions');
      final List<dynamic> rawData = response.data;
      return NoteReactionModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> addReaction(int noteId, int reactionTypeId) async {
    try {
      await _dio.post('/api/notes/$noteId/reactions/$reactionTypeId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> removeReaction(int noteId, int reactionTypeId) async {
    try {
      await _dio.delete('/api/notes/$noteId/reactions/$reactionTypeId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

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