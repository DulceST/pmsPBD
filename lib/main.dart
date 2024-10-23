import 'package:flutter/material.dart';
import 'package:pmspbd/screens/login_screen.dart';
import 'package:pmspbd/screens/register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazar App',
      home: LoginScreen(),
       debugShowCheckedModeBanner:false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
