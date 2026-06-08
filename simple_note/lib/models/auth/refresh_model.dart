
//Response from api
class RefreshResponse {
  final String message;
  final String accessToken;

  RefreshResponse({
    required this.message,
    required this.accessToken,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>?;
    return RefreshResponse(
      message: json['message'] ?? '',
      accessToken: tokens?['accessToken'] ?? json['accessToken'] ?? '',
    );
  }
}