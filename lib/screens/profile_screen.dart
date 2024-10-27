import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isNameEditable = false;
  bool isEmailEditable = false;
  bool isPasswordEditable = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //Carga los datos del usuario desde la bd 
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        nameController.text = userData['name'];
        emailController.text = userData['email'];
        profileImageUrl = userData['imgProfile'];
      });
    }
  }


  //Actualiza los datos del usuario 
  Future<void> _updateUserProfile() async {
  final user = _auth.currentUser;
  if (user != null) {
    // Reautenticación si hay una nueva contraseña
    if (passwordController.text.isNotEmpty) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: await _getCurrentPassword(),
      );
      try {
        // Reautenticar al usuario antes de cambiar la contraseña
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reautenticar: ${e.toString()}')),
        );
        return; // Detener ejecución si ocurre un error de reautenticación
      }
    }

    // Actualizar datos del perfil en Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'name': nameController.text,
      'email': emailController.text,
      'imgProfile': profileImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado con éxito')),
    );

    // Recargar los datos del usuario en la interfaz para refrescar la imagen
    await _loadUserData();
  }
}

// Método para solicitar la contraseña actual al usuario
Future<String> _getCurrentPassword() async {
  String currentPassword = '';
  await showDialog(
    context: context,
    builder: (context) {
      final passwordController = TextEditingController();
      return AlertDialog(
        title: Text('Confirma tu contraseña'),
        content: TextField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'Contraseña actual'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              currentPassword = passwordController.text;
              Navigator.of(context).pop();
            },
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );
  return currentPassword;
}


  
  //Metodo para seleccionar la imagen de perfil 
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccionar Imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Tomar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Seleccionar de la Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        profileImageUrl = pickedImage.path; // Temporalmente solo la ruta local
      });
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      showDialog(
        context: context,
        builder: (context) {
          final passwordController = TextEditingController();
          return AlertDialog(
            title: Text('¿Estás seguro?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Para eliminar tu cuenta, ingresa tu contraseña.',
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text,
                  );

                  try {
                    await user.reauthenticateWithCredential(credential);
                    await _firestore.collection('users').doc(user.uid).delete();
                    await user.delete();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cuenta eliminada')),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Eliminar cuenta'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            enabled: isEditable,
          ),
        ),
        IconButton(
          icon: Icon(isEditable ? Icons.check : Icons.edit),
          onPressed: onEdit,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl != null
                    ? CachedNetworkImageProvider(profileImageUrl!)
                    : AssetImage('assets/default_avatar.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            _buildEditableField(
              label: 'Nombre',
              controller: nameController,
              isEditable: isNameEditable,
              onEdit: () => setState(() => isNameEditable = !isNameEditable),
            ),
            _buildEditableField(
              label: 'Correo electrónico',
              controller: emailController,
              isEditable: isEmailEditable,
              onEdit: () => setState(() => isEmailEditable = !isEmailEditable),
            ),
            _buildEditableField(
              label: 'Nueva Contraseña',
              controller: passwordController,
              isEditable: isPasswordEditable,
              onEdit: () => setState(() => isPasswordEditable = !isPasswordEditable),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: const Text('Guardar Cambios'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _deleteAccount,
              child: const Text(
                'Eliminar Cuenta',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
