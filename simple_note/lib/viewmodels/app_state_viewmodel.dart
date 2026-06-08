import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_note/services/dio_client.dart';
import '../services/secure_storage_service.dart';

//Available app states
enum AppState { loading, onboarding, unauthenticated, authenticated }

class AppStateViewModel extends ChangeNotifier{
  AppState _currentState = AppState.loading;
  AppState get currentState => _currentState;

  AppStateViewModel() {
    initializeAppState();
  }

  Future<void> initializeAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      //Chech if user saw onboarding page
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      if (!hasSeenOnboarding) {
        _currentState = AppState.onboarding;
        notifyListeners();
        return;
      }

      //Check if access token exists
      final accessToken = await SecureStorageService.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        _currentState = AppState.authenticated;
        notifyListeners();
        return;
      }

      // Silent refresh
      final refreshDio = Dio(DioClient().dio.options);
      refreshDio.interceptors.addAll(DioClient().dio.interceptors.whereType<CookieManager>());
      
      //Try to get new access token
      final response = await refreshDio.post('/api/auth/refresh');
      final newAccessToken = response.data['accessToken'];
      
      if (newAccessToken != null) {
        await SecureStorageService.saveAccessToken(newAccessToken);
        _currentState = AppState.authenticated;
      } else {
        _currentState = AppState.unauthenticated;
      }
    } catch (e) {
      //Refresh unsuccessfull - navigate to login page
      _currentState = AppState.unauthenticated;
    } finally {
      notifyListeners();
    }
  }


  //User saw onboarding for first time
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    //Update state
    await prefs.setBool('hasSeenOnboarding', true);
    _currentState = AppState.unauthenticated;
    notifyListeners();
  }


  //If user loggs in
  void loginSuccess() {
    _currentState = AppState.authenticated;
    notifyListeners();
  }


  //Logout
  void logoutSuccess() {
    _currentState = AppState.unauthenticated;
    notifyListeners();
  }


}