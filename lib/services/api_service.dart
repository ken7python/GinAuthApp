import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:8080/api"));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ユーザー登録
  Future<String?> register(String username, String password) async {
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
    try{
      final response = await _dio.post("accounts/login", data: {
        "username": username,
        "password": password,
      });
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: "jwt_token", value: token);
        return token;
      }
    } catch (e) {
      return "Error: $e";
    }
  }
  //プロフィール取得(JWT必須)
  Future<Map<String, dynamic>?> getProfile() async {
    try{
      final token = await _storage.read(key: "jwt_token");
      if (token == null) return null;

      final response = await _dio.get("accounts/profile", options: Options(
        headers: {"Authorization": "Bearer $token"},),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

}