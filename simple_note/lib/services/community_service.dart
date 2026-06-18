import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/community/community_note_model.dart';

class CommunityService {
  final Dio _dio = DioClient().dio;

  //pobieranie listy publicznych notatek
  Future<List<CommunityNoteModel>> getPublicNotes({
    String? phrase,
    String? subject,
    String? tag,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      
      if (phrase != null && phrase.trim().isNotEmpty) {
        queryParameters['phrase'] = phrase.trim();
      }
      if (subject != null && subject.trim().isNotEmpty) {
        queryParameters['subject'] = subject.trim();
      }
      if (tag != null && tag.trim().isNotEmpty) {
        queryParameters['tag'] = tag.trim();
      }

      final response = await _dio.get(
        '/api/community/notes', 
        queryParameters: queryParameters,
      );

      final List<dynamic> rawData = response.data;
      return CommunityNoteModel.fromJsonList(rawData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  //pobieranie szczegółów publicznej notatki
  Future<CommunityNoteModel> getPublicNoteById(int noteId) async {
    try {
      final response = await _dio.get('/api/community/notes/$noteId');
      
      if (response.data == null) {
        throw Exception('Nie znaleziono podanej notatki publicznej.');
      }

      final Map<String, dynamic> rawData = response.data;
      return CommunityNoteModel.fromJson(rawData);
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