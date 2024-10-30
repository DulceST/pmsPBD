import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pmspbd/screens/history_screen.dart';
import 'package:pmspbd/screens/product_screen.dart';
import 'package:pmspbd/screens/sales_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDay = DateTime.now();
  int _pendingSalesCount = 0; // Contador de ventas "por cumplir"

  @override
  void initState() {
    super.initState();
    _fetchPendingSalesCount(); // Cargar la cantidad de ventas por cumplir al iniciar
  }

    // Método para contar ventas "por cumplir"
  Future<void> _fetchPendingSalesCount() async {
    final snapshot = await _firestore
        .collection('sales')
        .where('status', isEqualTo: 'por cumplir')
        .get();

    setState(() {
      _pendingSalesCount = snapshot.docs.length; // Actualiza el contador
    });
  }


  // Escucha en tiempo real las ventas "por cumplir"
  Stream<int> _pendingSalesStream() {
    return _firestore
        .collection('sales')
        .where('status', isEqualTo: 'por cumplir')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
  int _pendingSalesCount = 0; // Contador de ventas "por cumplir"

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height, // Altura del modal
          width: MediaQuery.of(context).size.width, // Ancho del modal
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).primaryColor, // Color de fondo del título
                child: Text(
                  'Eventos para ${DateFormat('EEEE, d MMMM yyyy').format(day)}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Expanded(
  child: SingleChildScrollView(
    child: ListBody(
      children: events.isEmpty
          ? [const Text('No hay eventos para este día')]
          : events.map((event) {
              final title = event['client'] ?? 'Sin cliente'; // Manejo de nulos
              final status = event['status'] ?? 'desconocido'; // Manejo de nulos
              final amout = event['amout'] ?? '0';
              final subtotal = event['subtotal'] ?? '0';
              final unitprice = event['unit_price'] ?? '0';
              final productId = event['product_id']; 


              // Retornar un FutureBuilder para obtener detalles del producto
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('Products').doc(productId).get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Cargando producto...'),
                    );
                  }
                  if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                    return ListTile(
                      title: Text(title),
                      subtitle: const Text('Producto no encontrado.'),
                      trailing: Container(
                        width: 12, // Ancho del círculo
                        height: 12, // Alto del círculo
                        decoration: BoxDecoration(
                          color: _getStatusColor(status), // Color según el estado
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.0), // Borde negro
                        ),
                      ),
                    );
                  }

                  // Obtener el nombre del producto
                  final productData = productSnapshot.data!.data() as Map<String, dynamic>;
                  final productName = productData['product'] ?? 'Sin producto';

                  return ListTile(
                    title: Text(title),
                    subtitle: Text(
                      'Producto: $productName\nCantidad: $amout\nSubtotal: $subtotal\nPiezas por unidad: $unitprice\nEstado: $status',
                    ),
                    trailing: Container(
                      width: 12, // Ancho del círculo
                      height: 12, // Alto del círculo
                      decoration: BoxDecoration(
                        color: _getStatusColor(status), // Color según el estado
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.0), // Borde negro
                      ),
                    ),
                  );
                },
              );
            }).toList(),
                  ),
                ),
              ),
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
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
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'por cumplir':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'completado':
        return Colors.white;
      default:
        return Colors.black; // Color por defecto si no hay coincidencia
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar de Ropa'),
        actions: [
          // Escuchar el stream y mostrar el badge dinámicamente
          StreamBuilder<int>(
            stream: _pendingSalesStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0; // Fallback a 0 si no hay datos

              return badges.Badge(
                badgeContent: Text(
                  '$count', // Muestra la cantidad de ventas por cumplir
                  style: const TextStyle(color: Colors.white),
                ),
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag),
                  onPressed: () {
                    // Navegar a la pantalla del carrito de compras
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductScreen()),
                    );
                  },
                ),
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

        // Contar eventos por día e imprimir en consola
        _countEventsPerDay(salesData);

        return TableCalendar(
          focusedDay: _selectedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          eventLoader: (day) {
            // Filtrar eventos asegurándose de que el campo `date` existe y no es `null`
            final eventsForDay = salesData.where((sale) {
              if (sale['date'] != null) {
                final saleDate = (sale['date'] as Timestamp).toDate();
                return saleDate.year == day.year &&
                    saleDate.month == day.month &&
                    saleDate.day == day.day;
              }
              return false;
            }).toList();

            // Devuelve una lista con la cantidad de eventos como puntos
            return List.generate(eventsForDay.length, (index) {
              return Container(
                margin: const EdgeInsets.only(
                    top: 2), // Margen superior para espacio
                width: 8, // Ancho de la bolita
                height: 8, // Alto de la bolita
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      eventsForDay[index]['status']), // Color según el estado
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
              );
            });
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

//metodo que cuenta los eventos por dia
  void _countEventsPerDay(List<Map<String, dynamic>> salesData) {
    Map<DateTime, int> eventsCountMap = {};

    // Contar los eventos por fecha
    for (var sale in salesData) {
      if (sale['date'] != null) {
        DateTime date = (sale['date'] as Timestamp).toDate();
        DateTime key = DateTime(date.year, date.month, date.day);

        // Incrementar el contador para la fecha
        if (eventsCountMap.containsKey(key)) {
          eventsCountMap[key] = eventsCountMap[key]! + 1;
        } else {
          eventsCountMap[key] = 1;
        }
      }
    }

    // Imprimir el conteo de eventos por día en la consola
    eventsCountMap.forEach((date, count) {
      print(
          'Fecha: ${DateFormat('d MMMM yyyy').format(date)}, Eventos: $count');
    });
  }
}
