import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/auth/me_model.dart';

class UserService {
  final Dio _dio;

  const UserService({required Dio dio}) : _dio = dio;

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/api/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
}