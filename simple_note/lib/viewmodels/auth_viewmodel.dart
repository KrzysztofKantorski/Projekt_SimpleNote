import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth/login_model.dart';
import '../models/auth/register_model.dart';

class AuthViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  //Login method

  Future<bool> login(String username, String password) async {
    _startLoading();
    try {
      final request = LoginRequest(
        username: username, 
        password: password
      );
      await _authService.login(request);
      _stopLoading();
      return true;
    } 
    catch (e) {
      _handleError(e);
      return false;
    } 
  }


  //Register method

  Future<bool> register(String username, String password) async {
    _startLoading();
    try {
      final request = RegisterRequest(
        username: username, 
        password: password
      );
      await _authService.register(request);
      _stopLoading();
      return true; 
    } 
    catch (e) {
    _handleError(e);
      return false;
    } 
  }


  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
       _handleError(e);
    } 
  }

  //Clear errors from previous actions
  void _startLoading() {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _isLoading = false;
    _errorMessage = error.toString().replaceAll('Exception: ', '');
    notifyListeners();
  }


  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}