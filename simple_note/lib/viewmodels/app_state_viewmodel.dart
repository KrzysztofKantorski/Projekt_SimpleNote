import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_note/services/dio_client.dart';
import '../services/secure_storage_service.dart';

enum AppState { loading, onboarding, unauthenticated, authenticated }

class AppStateViewModel extends ChangeNotifier {
  AppState _currentState = AppState.loading;
  AppState get currentState => _currentState;

  AppStateViewModel() {
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      if (!hasSeenOnboarding) {
        _currentState = AppState.onboarding;
        notifyListeners();
        return;
      }

      final accessToken = await SecureStorageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        _currentState = AppState.authenticated;
        notifyListeners();
        return;
      }

      final refreshDio = Dio(DioClient().dio.options);
      refreshDio.interceptors
          .addAll(DioClient().dio.interceptors.whereType<CookieManager>());

      final response = await refreshDio.post('/api/auth/refresh');
      final newAccessToken = response.data['accessToken'];

      if (newAccessToken != null) {
        await SecureStorageService.saveAccessToken(newAccessToken);
        _currentState = AppState.authenticated;
      } else {
        _currentState = AppState.unauthenticated;
      }
    } catch (_) {
      _currentState = AppState.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    _currentState = AppState.unauthenticated;
    notifyListeners();
  }

  void loginSuccess() {
    _currentState = AppState.authenticated;
    notifyListeners();
  }

  void logoutSuccess() {
    _currentState = AppState.unauthenticated;
    notifyListeners();
  }
}