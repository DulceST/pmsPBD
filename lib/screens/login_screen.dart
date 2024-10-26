import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final conUser = TextEditingController();
  final conPwd = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    TextFormField txtUser = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: conUser,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: const Icon(Icons.person, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final txtPwd = TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: conPwd,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final ctnCredentials = Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          txtUser,
          SizedBox(height: screenHeight * 0.02),
          txtPwd,
          SizedBox(height: screenHeight * 0.02),
          Align(
            alignment:
                Alignment.centerRight, // Alinea el texto al centro de su contenedor
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );

    final btnLogin = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        setState(() => isLoading = true);
        Future.delayed(const Duration(milliseconds: 3000), () {
          setState(() => isLoading = false);
          Navigator.pushNamed(context, "/home");
        });
      },
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('Iniciar sesión',
              style: TextStyle(fontSize: screenWidth * 0.05)),
    );

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Image.asset(
                'assets/logo.png',
                width: screenWidth * 0.4,
              ),*/
              SizedBox(height: screenHeight * 0.05),
              ctnCredentials,
              SizedBox(height: screenHeight * 0.05),
              SizedBox(width: screenWidth * 0.85, child: btnLogin),
            ],
          ),
        ),
      ),
    );
  }
}
