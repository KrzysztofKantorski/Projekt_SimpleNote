import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/saved_note/saved_note_model.dart';

class SavedNoteService {
  final Dio _dio;

  const SavedNoteService({required Dio dio}) : _dio = dio;

  Future<List<SavedNoteModel>> getSavedNotes() async {
    try {
      final response = await _dio.get('/api/saved-notes');
      final List<dynamic> raw = response.data;
      return SavedNoteModel.fromJsonList(raw);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> addNoteToSaved(int noteId) async {
    try {
      await _dio.post('/api/saved-notes/$noteId');
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> removeNoteFromSaved(int noteId) async {
    try {
      await _dio.delete('/api/saved-notes/$noteId');
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
}