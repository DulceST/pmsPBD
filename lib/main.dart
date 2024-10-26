import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pmspbd/screens/home_screen.dart';
import 'package:pmspbd/screens/login_screen.dart';
import 'package:pmspbd/screens/register_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

   try {
    await Firebase.initializeApp();
    print("Firebase se ha inicializado correctamente."); // Mensaje de consola
  } catch (e) {
    print("Error al inicializar Firebase: $e"); // Mensaje de error si falla
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazar App',
      home: const LoginScreen(),
       debugShowCheckedModeBanner:false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(), 
      },
    );
  }
}
