import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pmspbd/screens/history_screen.dart';
import 'package:pmspbd/screens/product_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
        .where('status',
            isEqualTo: 'por cumplir') // Filtra las ventas pendientes
        .snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


//funcion que convierte la fecha para que se pueda mostrar
  String _formatDate(dynamic dateValue) {
  if (dateValue == null) return 'N/A';

  DateTime dateTime;
  if (dateValue is Timestamp) {
    dateTime = dateValue.toDate(); // Convierte Timestamp a DateTime
  } else if (dateValue is DateTime) {
    dateTime = dateValue;
  } else {
    return 'Fecha no válida';
  }

  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime); // Formato deseado
}

void _showDetailsDialog(BuildContext context, Map<String, dynamic> saleData) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Detalles de la Venta'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Cliente: ${saleData['client']}'),
              Text('Fecha: ${_formatDate(saleData['date'])}'),
              Text('Estado: ${saleData['status']}'),
              Text('Piezas: ${saleData['amout']}'),
              Text('Precio unitario: \$${saleData['unit_price']}'),
              Text('Total: \$${saleData['subtotal']}'),
              // Agrega más información según sea necesario
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar de Ropa'),
      ),
      drawer: FutureBuilder<Map<String, dynamic>?>(
        // Usuario Drawer
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

      // Contenido principal de la pantalla con IndexedStack
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StreamBuilder<QuerySnapshot>(
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title:
                            Text('Cliente : ${saleData['client']}'),
                        subtitle: Text(
                          'Fecha: ${_formatDate(saleData['date'])}',
                          
                        ),
                        trailing: Text(saleData['status']),
                        onTap: () {
                          _showDetailsDialog(context, saleData);
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
          const HistoryScreen(),
          const ProductScreen(),
        ],
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Products'),
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
