import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar de Ropa'),
      ),
      drawer: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text("Error al cargar datos del usuario"));
          } else {
            final userData = snapshot.data!;
            return _myDrawer(context, userData);
          }
        },
      ),
      body: const Center(
        child: Text('Contenido de la página principal'),
      ),
    );
  }

  Widget _myDrawer(BuildContext context, Map<String, dynamic> userData) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: CachedNetworkImage(
                imageUrl:
                    userData['imgProfile'] ?? 'assets/default_avatar.jpg',
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                ),
              ),
            ),
            accountName: Text(userData['name'] ?? 'Nombre no disponible'),
            accountEmail: Text(userData['email'] ?? 'Correo no disponible'),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            title: const Text('Perfil'),
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
