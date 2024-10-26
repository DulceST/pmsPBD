import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatelessWidget {
  // Datos simulados para ventas pendientes
  final List<Map<String, dynamic>> ventasPendientes = [
    {
      "nombre": "Venta de pantalones",
      "estado": "por cumplir",
      "fecha": "2024-10-22"
    },
    {
      "nombre": "Venta de zapatos",
      "estado": "por cumplir",
      "fecha": "2024-10-23"
    },
  ];

  // Datos simulados para el calendario
  final Map<DateTime, List<Map<String, dynamic>>> eventos = {
    DateTime(2024, 10, 22): [
      {"nombre": "Venta de pantalones", "estado": "por cumplir"},
    ],
    DateTime(2024, 10, 23): [
      {"nombre": "Venta de zapatos", "estado": "por cumplir"},
    ],
    DateTime(2024, 10, 21): [
      {"nombre": "Servicio de sastrería", "estado": "cancelado"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar de Ropa'),
        actions: [
          badges.Badge(
            badgeContent:
                const Text('3', style: TextStyle(color: Colors.white)),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // Acción para mostrar el carrito de bienes agregados
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Ventas o Servicios Pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Listado de Ventas/Servicios Pendientes
            ListView.builder(
              shrinkWrap: true, // Para que funcione en SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Evita conflictos con el scroll
              itemCount: ventasPendientes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(ventasPendientes[index]['nombre']),
                    subtitle:
                        Text('Estado: ${ventasPendientes[index]['estado']}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Acción para ver los detalles de la venta/servicio pendiente
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Calendario para visualizar eventos
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Calendario de Ventas/Servicios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 1, 1),
              focusedDay: DateTime.now(),
              eventLoader: (day) {
                return eventos[day] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.map((event) {
                      Color color  = Colors.transparent;
                      if (event != null &&
                          event is Map<String, dynamic> &&
                          event['estado'] != null) {
                        switch (event['estado']) {
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
                            color = Colors.grey;
                            break;
                        }
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                // Acción al seleccionar un día en el calendario
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: eventos[selectedDay]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final evento = eventos[selectedDay]?[index];
                          return ListTile(
                            title: Text(evento != null && evento['nombre'] != null ? evento['nombre'] : 'Sin nombre'),
                            subtitle: Text('Estado: ${evento?['estado'] ?? 'Desconocido'}'),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Navegar a la pantalla de historial de ventas/servicios
          }
        },
      ),
    );
  }
}
