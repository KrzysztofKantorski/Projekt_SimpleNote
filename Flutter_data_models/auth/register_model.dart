class RegisterRequest {
  final String username;
  final String password;

  RegisterRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Password': password,
    };
  }
}

//Response from api
class RegisterResponse {
  final String message;

  RegisterResponse({
    required this.message,
  });

  
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
    );
  }
}