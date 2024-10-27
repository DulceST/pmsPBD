import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Obtiene los datos de usuario para usar en el drawer
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

  // Consulta para mostrar las ventas con un estado pendiente
  Stream<QuerySnapshot> _getSales() {
    return FirebaseFirestore.instance
        .collection('sales')
        .where('status', isEqualTo: 'por cumplir') // Filtra las ventas pendientes
        .snapshots();
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
      // Contenido principal del home
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar las ventas"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay ventas pendientes"));
          } else {
            final salesDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: salesDocs.length,
              itemBuilder: (context, index) {
                final saleData =
                    salesDocs[index].data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(saleData['client'] ?? 'Cliente no disponible'),
                    subtitle: Text('Fecha: ${saleData['date'] ?? 'N/A'}'),
                    trailing: Text(saleData['status']),
                    onTap: () {
                      // Acción al tocar el elemento
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/history');
              break;
            case 2:
              Navigator.pushNamed(context, '/products');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Productos'),
        ],
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
                imageUrl: userData['imgProfile'] ?? 'assets/default_avatar.jpg',
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
