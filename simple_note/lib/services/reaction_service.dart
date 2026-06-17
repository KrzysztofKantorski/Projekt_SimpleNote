import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/reaction/reaction_model.dart'; // Upewnij się, że ścieżka do Twoich modeli jest poprawna

class ReactionService {
  final Dio _dio = DioClient().dio;

  // 1. Pobieranie listy wszystkich dostępnych typów reakcji (Słownik)
  Future<List<ReactionTypeModel>> getAvailableReactions() async {
    try {
      final response = await _dio.get('/api/reaction-types'); // Dostosuj jeśli URL brzmi /api/reactions
      final List<dynamic> rawData = response.data;
      return ReactionTypeModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // 2. Pobieranie podsumowania reakcji dla konkretnej notatki
  Future<List<NoteReactionModel>> getNoteReactionsSummary(int noteId) async {
    try {
      final response = await _dio.get('/api/notes/$noteId/reactions');
      final List<dynamic> rawData = response.data;
      return NoteReactionModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // 3. Dodawanie reakcji do notatki (POST /api/notes/{noteId}/reactions/{reactionTypeId})
  Future<void> addReaction(int noteId, int reactionTypeId) async {
    try {
      await _dio.post('/api/notes/$noteId/reactions/$reactionTypeId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // 4. Usuwanie reakcji z notatki (DELETE /api/notes/{noteId}/reactions/{reactionTypeId})
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