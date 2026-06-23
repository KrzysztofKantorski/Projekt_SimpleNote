import '../models/auth/me_model.dart';
import '../services/user_service.dart';

abstract class UserRepository {
  Future<UserModel> getCurrentUser();
}

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  const UserRepositoryImpl({required UserService userService})
      : _userService = userService;

  @override
  Future<UserModel> getCurrentUser() => _userService.getMe();
}
