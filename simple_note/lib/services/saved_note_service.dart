import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/saved_note/saved_note_model.dart'; // Dostosuj ścieżkę do modelu jeśli trzeba

class SavedNoteService {
  final Dio _dio = DioClient().dio;

  /// 1. POBIERANIE LISTY ZAPISANYCH NOTATEK (GET /api/community/notes/saved)
  Future<List<SavedNoteModel>> getSavedNotes() async {
    try {
      final response = await _dio.get('/api/saved-notes');
      
      final List<dynamic> rawData = response.data;
      return SavedNoteModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// 2. DODAWANIE NOTATKI DO ZAPISANYCH (POST /api/community/notes/saved/{noteId})
  Future<void> addNoteToSaved(int noteId) async {
    try {
      await _dio.post('/api/saved-notes/$noteId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// 3. USUWANIE NOTATKI Z ZAPISANYCH (DELETE /api/community/notes/saved/{noteId})
  Future<void> removeNoteFromSaved(int noteId) async {
    try {
      await _dio.delete('/api/saved-notes/$noteId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// === DEKODOWANIE BŁĘDÓW BACKENDOWYCH ===
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data == null) return 'Błąd połączenia z serwerem (Status: ${e.response?.statusCode})';
    if (data is String) return data.trim().isNotEmpty ? data : 'Wystąpił nieoczekiwany błąd';
    
    if (data is Map) {
      if (data.containsKey('message') && data['message'] != null) return data['message'].toString();
      if (data.containsKey('title') && data['title'] != null) return data['title'].toString();
    }
    return 'Błąd serwera (Kod: ${e.response?.statusCode})';
  }
}