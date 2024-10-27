import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pmspbd/screens/history_screen.dart';
import 'package:pmspbd/screens/product_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDay = DateTime.now();
  late Map<DateTime, List<Map<String, dynamic>>> _events;

  @override
  void initState() {
    super.initState();
    _events = {};
  }

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


//Muestra en el calendario la venta correspondiente en el calendario
void _loadEventsForSelectedDay(DateTime date) {
    FirebaseFirestore.instance.collection('sales').get().then((snapshot) {
      setState(() {
        _events.clear(); // Limpiar eventos previos
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime eventDate = (data['date'] as Timestamp).toDate().toLocal();
          // Solo agregar eventos si coinciden con la fecha seleccionada
          if (eventDate.year == date.year &&
              eventDate.month == date.month &&
              eventDate.day == date.day) {
            if (!_events.containsKey(date)) {
              _events[date] = [];
            }
            _events[date]!.add(data);
          }
        }
      });
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _loadEventsForSelectedDay(selectedDay); 
    _showEventDetails(context, selectedDay);
  }

  //muestra el modal con los eventos del dia que se selecciono
  void _showEventDetails(BuildContext context, DateTime day) {
    // Mostrar modal con eventos del día
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<Map<String, dynamic>> events = _events[day] ?? [];
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(day),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (var event in events) ...[
                ListTile(
                  title: Text('Cliente: ${event['client']}'),
                  subtitle: Text('Estado: ${event['status']}'),
                  onTap: () => _showDetailsDialog(context, event),
                ),
              ],
              if (events.isEmpty) const Text('No hay eventos para este día.'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Aquí puedes agregar la lógica para finalizar la venta/servicio
                  Navigator.pop(context); // Cerrar modal
                },
                child: const Text('Finalizar Venta/Servicio'),
              ),
            ],
          ),
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
          Column(
            children: [
              // Sección de Ventas por Cumplir
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                              title: Text('Cliente : ${saleData['client']}'),
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
              ),

              // Sección del Calendario
              SizedBox(
                height: 400, // Ajusta la altura según sea necesario
                child: TableCalendar<Map<String, dynamic>>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  eventLoader: (day) {
                    return _events[day] ?? [];
                  },
                  calendarBuilders: CalendarBuilders(
                    todayBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      List<Map<String, dynamic>> events = _events[day] ?? [];
                      Color statusColor = Colors.transparent;

                      // Determina el color según el estado de los eventos
                      if (events.isNotEmpty) {
                        if (events.any((event) => event['status'] == 'por cumplir')) {
                          statusColor = Colors.white;
                        } else if (events.any((event) => event['status'] == 'cancelado')) {
                          statusColor = Colors.red;
                        } else {
                          statusColor = Colors.green;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(child: Text(day.day.toString())),
                      );
                    },
                  ),
                ),
              ),
            ],
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
