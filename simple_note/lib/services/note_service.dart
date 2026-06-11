import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/note/note_model.dart';

class NoteService {
  final Dio _dio = DioClient().dio;

  Future<List<NoteModel>> getNotes() async {
    try {
      //Get users notes
      final response = await _dio.get('/api/notes');
      final List<dynamic> rawData = response.data;
      return rawData.map((json) => NoteModel.fromJson(json)).toList();
    } 
    on DioException catch (e) {
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