import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GinAuth App",
      initialRoute: "/",
      routes: {
        "/": (context) => ProfileScreen(),
        "/profile": (context) => ProfileScreen(),
        "/register": (context) => RegisterScreen(),
        "/login": (context) => LoginScreen(),
      },
    );
  }
}