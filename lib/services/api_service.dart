import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://localhost:8080/api/",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ))
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
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
      final response = await _dio.post('accounts/register', data: {
        "username": username,
        "password": password,
      });

      if (response.data is Map && response.data.containsKey("error")) {
        return "Error: ${response.data["error"]}";
      }
      return response.data['message'] ?? "登録成功";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ログイン
  Future<String> login(String username, String password) async {
    print("login");
    try {
      final response = await _dio.post("accounts/login", data: {
        "username": username,
        "password": password,
      });

      final res = response.data;
      if (res is Map && res.containsKey("error")) {
        return "Error: ${res["error"]}";
      }

      final token = res["token"];
      if (token != null) {
        await saveToken(token);
        return token;
      }
      return "Error: トークンが見つかりません";
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      return "Error: ${e.message}";
    } on SocketException catch (e) {
      print("SocketException: ${e.message}");
      return "Error: No Internet connection";
    } catch (e) {
      print("Unexpected Error: $e");
      return "Error: $e";
    }
  }

  // プロフィール取得 (JWT 必須)
  Future<Map<String, dynamic>> getProfile() async {
    print("getProfile");
    try {
      final token = await getToken();
      if (token == null) return {"error": "ログインが必要です"};

      final response = await _dio.get("accounts/profile",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.data is Map && response.data.containsKey("error")) {
        return {"error": response.data["error"]};
      }
      return response.data;
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      return {"error": "通信エラー: ${e.message}"};
    } on SocketException catch (e) {
      print("SocketException: ${e.message}");
      return {"error": "インターネット接続がありません"};
    } catch (e) {
      print("Unexpected Error: $e");
      return {"error": "予期しないエラー: $e"};
    }
  }
}