import '../models/auth/login_model.dart';
import '../models/auth/register_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<void> login(String username, String password);
  Future<void> register(String username, String password);
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  const AuthRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  Future<void> login(String username, String password) =>
      _authService.login(LoginRequest(username: username, password: password));

  @override
  Future<void> register(String username, String password) =>
      _authService.register(
          RegisterRequest(username: username, password: password));

  @override
  Future<void> logout() => _authService.logout();
}
