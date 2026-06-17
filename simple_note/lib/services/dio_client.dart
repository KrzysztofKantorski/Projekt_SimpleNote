import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'secure_storage_service.dart';

class DioClient{
  static final DioClient _instance = DioClient._internal();

  late final Dio dio;

  bool _isRefreshing = false;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(BaseOptions(

      //Change to port from backend
      baseUrl: 'http://localhost:5168', 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  //Init method
  Future<void> init() async{

    //Cookies storage location
    final appDocDir = await getApplicationDocumentsDirectory();

    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );

    //Add interceptor
    dio.interceptors.add(CookieManager(cookieJar));


    //Add main interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          // Get access token
          final accessToken = await SecureStorageService.getAccessToken();

          //Access token is valid
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {

          // Server returned 401 - token expired
          if (e.response?.statusCode == 401) {

            //send request for token refresh
            final refreshed = await _refreshToken();
            
            if (refreshed) {

              // Update access token, retry request
              final newAccessToken = await SecureStorageService.getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              
              try {
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } 
              catch (retryError) {
                return handler.next(retryError as DioException);
              }
            } 
            else {
              // Token refresh was not successfull
              await SecureStorageService.deleteAccessToken();
              // Tutaj można dodać logikę wylogowania użytkownika i rzucenia do ekranu logowania
            }
          }
          return handler.next(e);
        },
      ),
    );

  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    
    try {

      // Creter separate dio instance
      final refreshDio = Dio(dio.options);

      // Add cookie manager 
      refreshDio.interceptors.addAll(dio.interceptors.whereType<CookieManager>());

      //Send request for token refresh
      final response = await refreshDio.post('/api/auth/refresh');
      
      // Get access token from api response
      final newAccessToken = response.data['accessToken'];
      
      if (newAccessToken != null) {

        //Save access token to cookie manager
        await SecureStorageService.saveAccessToken(newAccessToken);
        _isRefreshing = false;
        return true;
      }
      
      _isRefreshing = false;
      return false;
    } catch (e) {
      _isRefreshing = false;
      return false;
    }
  }

}