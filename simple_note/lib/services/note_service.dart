import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/note/note_model.dart';
import '../models/note/update_note_model.dart';

class NoteService {
  final Dio _dio;

  const NoteService({required Dio dio}) : _dio = dio;

  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await _dio.get('/api/notes');
      final List<dynamic> raw = response.data;
      return raw.map((json) => NoteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
  Future<NoteModel> getNoteById(int id) async {
  try {
    final response = await _dio.get('/api/notes/$id');
    return NoteModel.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception(extractDioErrorMessage(e));
  }
}
  Future<NoteModel> addNote({
    required String title,
    required String content,
    String? subjectName,
    List<String>? tagNames,
    bool isPublic = true,
  }) async {
    try {
      final response = await _dio.post('/api/notes', data: {
        'title': title,
        'content': content,
        'subjectName': subjectName,
        'tagNames': tagNames ?? [''],
        'isPublic': isPublic,
      });
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<NoteModel> editNote({
    required int id,
    required UpdateNoteRequest request,
  }) async {
    try {
      final response =
          await _dio.put('/api/notes/$id', data: request.toJson());
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
  Future<void> deleteNote(int id) async {
  try {
    await _dio.delete('/api/notes/$id');
  } on DioException catch (e) {
    throw Exception(extractDioErrorMessage(e));
  }
}
}