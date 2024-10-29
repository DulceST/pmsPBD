import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedDay = DateTime.now();

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

  // Mostrar modal con los eventos del día seleccionado
  void _showEventsForDay(DateTime day) async {
    // Obtener los eventos del día seleccionado
    final events = await _getEventsForDay(day);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Eventos para ${DateFormat('EEEE, d MMMM yyyy').format(day)}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: events.isEmpty
                  ? [const Text('No hay eventos para este día')]
                  : events.map((event) {
                      final title =
                          event['client'] ?? 'Sin cliente'; // Manejo de nulos
                      final status =
                          event['status'] ?? 'desconocido'; // Manejo de nulos
                      final eventDate = (event['date'] as Timestamp).toDate();
                      final formattedEventDate =
                          DateFormat('d MMMM yyyy').format(eventDate);

                      return ListTile(
                        title: Text(title),
                        subtitle: Text('Estatus: $status\nFecha: $formattedEventDate'),
                        trailing: _getStatusColor(status),
                      );
                    }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Obtener eventos para un día específico
  Future<List<Map<String, dynamic>>> _getEventsForDay(DateTime day) async {
    final snapshot = await _firestore.collection('sales').get();
    final salesData =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    return salesData.where((sale) {
      if (sale['date'] != null) {
        final saleDate = (sale['date'] as Timestamp).toDate();
        return saleDate.year == day.year &&
            saleDate.month == day.month &&
            saleDate.day == day.day;
      }
      return false;
    }).toList();
  }

// Obtener color según el estado de la venta
  Widget _getStatusColor(String status) {
    Color color;
    switch (status) {
      case 'por cumplir':
        color = Colors.green;
        break;
      case 'cancelado':
        color = Colors.red;
        break;
      case 'completado':
        color = Colors.white;
        break;
      default:
        color = Colors.black; // Color por defecto si no hay coincidencia
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
         border: Border.all(color: Colors.black, width: 1.0), 
      ),
    );
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
                MaterialPageRoute(builder: (context) => ProductScreen()),
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
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
          focusedDay: _selectedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          eventLoader: (day) {
            // Filtrar eventos asegurándose de que el campo `date` existe y no es `null`
            return salesData
                .where((sale) =>
                    sale['date'] != null &&
                    (sale['date'] as Timestamp).toDate().isAtSameMomentAs(day))
                .toList();
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            _showEventsForDay(
                selectedDay); // Muestra eventos al seleccionar el día
          },
        );
      },
    );
  }
}
