import 'package:flutter/foundation.dart';
import '../models/auth/me_model.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserViewModel({required UserRepository repository})
      : _repository = repository;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCurrentUser() async {
    _start();
    try {
      _user = await _repository.getCurrentUser();
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  void clearUser() {
    _user = null;
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

  String _clean(dynamic e) => e.toString().replaceAll('Exception: ', '');
}