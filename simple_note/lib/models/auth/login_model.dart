class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Password': password,
    };
  }
}


//Response from api
class LoginResponse {
  final String message;
  final String accessToken; 

  LoginResponse({
    required this.message,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>?; 
    return LoginResponse(
      message: json['message'] ?? '',
      accessToken: tokens?['accessToken'] ?? json['accessToken'] ?? '',
    );
  }
}