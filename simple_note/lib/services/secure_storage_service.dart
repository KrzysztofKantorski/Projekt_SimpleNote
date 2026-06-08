import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService{
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'ACCESS_TOKEN';

  //Save token to secure storage
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  //Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }


  //Delete access token if session expires
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

}