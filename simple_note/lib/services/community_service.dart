import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/community/community_note_model.dart';

class CommunityService {
  final Dio _dio;

  const CommunityService({required Dio dio}) : _dio = dio;

  Future<List<CommunityNoteModel>> getPublicNotes({
    String? phrase,
    String? subject,
    String? tag,
  }) async {
    try {
      final response = await _dio.get('/api/community/notes',
          queryParameters: {
            if (phrase != null && phrase.trim().isNotEmpty) 'phrase': phrase.trim(),
            if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
            if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
          });
      final List<dynamic> raw = response.data;
      return CommunityNoteModel.fromJsonList(raw);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<CommunityNoteModel> getPublicNoteById(int noteId) async {
    try {
      final response = await _dio.get('/api/community/notes/$noteId');
      if (response.data == null) {
        throw Exception('Nie znaleziono podanej notatki publicznej.');
      }
      return CommunityNoteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
  Future<List<String>> getSubjects() async {
    try {
      final response = await _dio.get('/api/dictionaries/subjects');
      
      if (response.data is List) {
        return List<String>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

}