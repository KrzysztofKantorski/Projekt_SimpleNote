import 'package:dio/dio.dart';
import 'secure_storage_service.dart';
import 'dio_error_helper.dart';
import '../models/auth/register_model.dart';
import '../models/auth/login_model.dart';
import '../models/auth/logout_model.dart';

class AuthService {
  final Dio _dio;

  const AuthService({required Dio dio}) : _dio = dio;

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response =
          await _dio.post('/api/auth/register', data: request.toJson());
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response =
          await _dio.post('/api/auth/login', data: request.toJson());
      final loginResponse = LoginResponse.fromJson(response.data);
      await SecureStorageService.saveAccessToken(loginResponse.accessToken);
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout');
      await SecureStorageService.deleteAccessToken();
      return LogoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      await SecureStorageService.deleteAccessToken();
      throw Exception(extractDioErrorMessage(e));
    }
  }
}