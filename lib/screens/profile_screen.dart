import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;

  void _logout(BuildContext context) async {
    await _apiService.logout();
    Navigator.pushReplacementNamed(context, '/login');  // ログイン画面へ遷移
  }

  void _loadProfile() async {
    final profile = await _apiService.getProfile();
    if (profile.containsKey("error")) {
      print("Error: ${profile["error"]}");
      _logout(context);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _profile = profile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("プロフィール")),
      body: Center(
        child: _profile == null ? CircularProgressIndicator() : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ユーザー名: ${_profile!["username"]}"),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text("ログアウト"),
            ),
          ],
        ),
      )
    );
  }
}