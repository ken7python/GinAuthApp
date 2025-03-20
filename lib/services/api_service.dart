import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:8080/api/",connectTimeout: Duration(seconds: 10),  // 10秒に設定
  receiveTimeout: Duration(seconds: 10),))
  ..options.extra["lookupOverride"] = (String host) async {
    return InternetAddress.lookup(host, type: InternetAddressType.IPv4);
  };
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("Dio Request: ${options.method} ${options.path}");
        print("Headers: ${options.headers}");
        print("Data: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Dio Response: ${response.statusCode}");
        print("Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("Dio Error: ${e.message}");
        if (e.response != null) {
          print("Status Code: ${e.response?.statusCode}");
          print("Response Data: ${e.response?.data}");
        }
        return handler.next(e);
      },
    ));
  }

  // ユーザー登録
  Future<String?> register(String username, String password) async {
    print("register");
    try {
      final response = await _dio.post('accounts/register',data:{
        "username": username,
        "password": password,
      });
      return response.data['message'];
    } catch (e) {
      return "Error: $e";
    }
  }
  //ログイン
  Future<String?> login(String username, String password) async {
    print("login");
    try{
      final response = await _dio.post("accounts/login", data: {
        "username": username,
        "password": password,
      });
      final token = response.data['token'];
      if (token != null) {
        await saveToken(token);
        return token;
      }
    } on DioException catch (e) {
    print("Dio Error: ${e.message}");
    if (e.response != null) {
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
    }
    return "Error: ${e.message}";
  } on SocketException catch (e) {
    print("SocketException: ${e.message}");
    return "Error: No Internet connection";
  } catch (e) {
    print("Unexpected Error: $e");
    return "Error: $e";
  }
  }
  //プロフィール取得(JWT必須)
  Future<Map<String, dynamic>?> getProfile() async {
    print("getProfile");
    try{
      final token = await getToken();
      print(token);
      if (token == null) return null;

      final response = await _dio.get("accounts/profile", options: Options(
        headers: {"Authorization": "Bearer $token"},),
      );
      print(response.data);
      return response.data;
    } catch (e) {
      print(e);
      return null;
    }
  }

}