import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/auth/me_model.dart';

class UserService {
  final Dio _dio = DioClient().dio;

  Future<UserModel> getMe() async {
    try {
      //Get info about user
      final response = await _dio.get('/api/users/me');
      
      return UserModel.fromJson(response.data);
    } 
    on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    
    if (data == null) return 'Błąd komunikacji z serwerem (Kod: ${e.response?.statusCode})';
    
    if (data is String) {
      return data.trim().isNotEmpty ? data : 'Wystąpił błąd (Kod: ${e.response?.statusCode})';
    }

    if (data is List) {
      if (data.isNotEmpty && data.first is Map && data.first.containsKey('description')) {
        return data.first['description'].toString();
      }
      if (data.isNotEmpty && data.first is String) {
        return data.map((err) => err.toString()).join('\n');
      }
      return 'Błąd serwera (Lista)';
    }

    if (data is Map) {
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }
      if (data.containsKey('title') && data['title'] != null) {
        return data['title'].toString();
      }
    }

    return 'Wystąpił błąd serwera (Kod: ${e.response?.statusCode})';
  }
}