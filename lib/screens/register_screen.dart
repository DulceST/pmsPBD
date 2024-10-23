import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final conName = TextEditingController();
  final conEmail = TextEditingController();
  final conPwd = TextEditingController();
  final conPwdConfirm = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Campo de nombre
    TextFormField txtName = TextFormField(
      controller: conName,
      decoration: InputDecoration(
        labelText: 'Nombre',
        prefixIcon: Icon(Icons.person, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de correo electrónico
    TextFormField txtEmail = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: conEmail,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: Icon(Icons.email, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de contraseña
    final txtPwd = TextFormField(
      obscureText: true,
      controller: conPwd,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de confirmación de contraseña
    final txtPwdConfirm = TextFormField(
      obscureText: true,
      controller: conPwdConfirm,
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        prefixIcon: Icon(Icons.lock, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Contenedor de campos de credenciales
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
          txtName,
          SizedBox(height: screenHeight * 0.02),
          txtEmail,
          SizedBox(height: screenHeight * 0.02),
          txtPwd,
          SizedBox(height: screenHeight * 0.02),
          txtPwdConfirm,
        ],
      ),
    );

    // Botón de registro
    final btnRegister = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        if (conPwd.text != conPwdConfirm.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Las contraseñas no coinciden")),
          );
          return;
        }
        setState(() => isLoading = true);
        Future.delayed(const Duration(milliseconds: 3000), () {
          setState(() => isLoading = false);
          Navigator.pop(context); // Volver al login después de registrarse
        });
      },
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('Registrarse', style: TextStyle(fontSize: screenWidth * 0.05)),
    );

    // Icono de flecha para volver al login
    final iconBack = Positioned(
      top: screenHeight * 0.05,
      left: screenWidth * 0.05,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.08),
      ),
    );

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  ctnCredentials,
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(width: screenWidth * 0.85, child: btnRegister),
                ],
              ),
            ),
            iconBack, // Agregar el botón de regresar
          ],
        ),
      ),
    );
  }
}
