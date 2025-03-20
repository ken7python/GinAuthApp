import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _message = "";

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = "ユーザー名とパスワードを入力してください";
      });
      return;
    }

    String? token = await _apiService.login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() {
      _message = token ?? "ログイン失敗";
    });

    if (token != null){
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ログイン")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "ユーザー名"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "パスワード"),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: _login, child: Text("ログイン")),
            Text(_message),
          ],
        )
      )
    );
  }
}