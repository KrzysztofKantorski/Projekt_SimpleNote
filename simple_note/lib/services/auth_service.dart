import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'secure_storage_service.dart';
import '../models/auth/register_model.dart'; 
import '../models/auth/login_model.dart';
import '../models/auth/logout_model.dart';


class AuthService {
  final Dio _dio = DioClient().dio;

  //Register 

 Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/api/auth/register', data: request.toJson());
      return RegisterResponse.fromJson(response.data);
    } 
    on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }


  //Login

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/api/auth/login', data: request.toJson());
      final loginResponse = LoginResponse.fromJson(response.data);
      
      //Save access token
      await SecureStorageService.saveAccessToken(loginResponse.accessToken);
      
      return loginResponse;
    } 
    on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }



  //Logout
  
  Future<LogoutResponse> logout() async {
    try {
      //Send request to api
      final response = await _dio.post('/api/auth/logout');
      
      //Remove access token
      await SecureStorageService.deleteAccessToken();
      return LogoutResponse.fromJson(response.data);
    } 
    on DioException catch (e) {
      await SecureStorageService.deleteAccessToken(); 
      throw Exception(_extractErrorMessage(e));
    }
  }


  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    
    //No response - server went down
    if (data == null) return 'Wystąpił błąd komunikacji z serwerem';

    //Backend returned plain text
    if (data is String) return data;

    //Error list
    if (data is List) {
      if (data.isNotEmpty) {
        if (data.first is String) {
          return data.map((error) => error.toString()).join('\n');
        }
        if (data.first is Map && data.first.containsKey('description')) {
          return data.first['description'].toString(); 
        }
      }
      return 'Błąd walidacji danych wejściowych';
    }

    if (data is Map) {
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
           final firstErrorList = errors.values.first;
           if (firstErrorList is List && firstErrorList.isNotEmpty) {
             return firstErrorList.first.toString();
           }
        }
        if (errors is List && errors.isNotEmpty && errors.first is String) {
          return errors.join('\n');
        }
      }
      
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }

      if (data.containsKey('title') && data['title'] != null) {
        return data['title'].toString();
      }
    }

    return 'Wystąpił nieznany błąd serwera (Kod: ${e.response?.statusCode})';
  }


}
