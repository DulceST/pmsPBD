import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar Firestore
import 'dart:convert';
import 'package:crypto/crypto.dart';

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

  Future<void> registerUser() async {
    String name = conName.text;
    String email = conEmail.text;
    String password = conPwd.text;

    if(name.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa tu nombre.')),
      );
      return; 
    }else if(email.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa tu correo electronico.')),
      );
      return; 
    }else if(password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa tu contraseña.')),
      );
      return; 
    }else{
      if (password != conPwdConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    // Encriptar la contraseña
    String encryptedPassword = encryptPassword(password);

    setState(() {
      isLoading = true;
    });

    try {
      // Registrar el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password, // Almacenar la contraseña en texto plano, Firebase la encriptará
      );

      // Obtener el ID del usuario registrado
      String userId = userCredential.user?.uid ?? '';

      // Guardar el nombre y la contraseña encriptada en Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'password': encryptedPassword, // Guarda la contraseña encriptada
        'imgProfile': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado con éxito")),
      );

      // Volver al login después de registrarse
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    }
  }

  String encryptPassword(String password) {
    // Encriptación de la contraseña usando SHA-256
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Campo de nombre
    TextFormField txtName = TextFormField(
      controller: conName,
      decoration: InputDecoration(
        labelText: 'Nombre',
        prefixIcon: const Icon(Icons.person, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de correo electrónico
    TextFormField txtEmail = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: conEmail,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: const Icon(Icons.email, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de contraseña
    final txtPwd = TextFormField(
      obscureText: true,
      controller: conPwd,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Campo de confirmación de contraseña
    final txtPwdConfirm = TextFormField(
      obscureText: true,
      controller: conPwdConfirm,
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
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
      onPressed: isLoading ? null : registerUser, // Llama a la función de registro
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
