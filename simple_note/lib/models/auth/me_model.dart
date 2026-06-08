//Response
class UserModel {
  final int id;
  final String username;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
  });

  // Get response body - id, role, username
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}