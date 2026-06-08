import 'package:flutter/material.dart';
import '../models/auth/me_model.dart';
import '../services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //Get data
  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _user = await _userService.getMe();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  //Clear state after logout
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}