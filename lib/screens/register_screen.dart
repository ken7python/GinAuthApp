import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _message = "";
  bool _isLoading = false;

  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = "ユーザー名とパスワードを入力してください";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = "登録中...";
    });

    String? res = await _apiService.register(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() {
      _isLoading = false;
      if (res == null) {
        _message = "登録失敗: ${res ?? "不明なエラー"}";
      }else if (res.startsWith("Error")){
        _message = "登録失敗: $res";
      } else{
        _message = "登録成功: $res";
      }
    });

    if (res != null && !res.startsWith("Error")) {
      await _apiService.logout();
      await _apiService.login(_usernameController.text, _passwordController.text);
      /*
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/profile');
      });
      */
      Navigator.pushReplacementNamed(context, '/profile');
    }
}

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ユーザー登録")),
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
            ElevatedButton(onPressed: _isLoading ? null : _register, child: Text("登録")),
            Text(_message),
          ],
        )
      )
    );
  }
}