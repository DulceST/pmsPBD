import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pmspbd/screens/history_screen.dart';
import 'package:pmspbd/screens/product_screen.dart';
import 'package:pmspbd/screens/sales_screen.dart';
import 'package:table_calendar/table_calendar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  //Manejar la navegacion de la barra
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar de Ropa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              // Navegar a la pantalla del carrito de compras
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProductScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildCalendar(),
          const HistoryScreen(),
          SalesScreen(),
        ],
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: 'Sales'),
        ],
      ),
    );
  }

  // Método que construye el calendario
  Widget _buildCalendar() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('sales').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        // Procesar los datos de Firebase para el calendario
        final salesData = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          eventLoader: (day) {
            // Filtrar eventos asegurándose de que el campo `date` existe y no es `null`
            return salesData.where((sale) =>
                sale['date'] != null &&
                (sale['date'] as Timestamp).toDate().isAtSameMomentAs(day)).toList();
          },
        );
      },
    );
  }

}
