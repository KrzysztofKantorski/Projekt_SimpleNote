import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    debugPrint("viewmodel");
    _start();
    try {
      await _repository.login(username, password);
      _stop();
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    _start();
    try {
      await _repository.register(username, password);
      _stop();
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _repository.logout();
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // helpers

  void _start() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stop() {
    _isLoading = false;
    notifyListeners();
  }

  void _fail(dynamic error) {
    _isLoading = false;
    _errorMessage = error.toString().replaceAll('Exception: ', '');
    notifyListeners();
  }
}