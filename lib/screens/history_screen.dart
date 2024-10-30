import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmspbd/firebase/database_sales.dart';
import 'package:pmspbd/firebase/database_products.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseSales databaseSales = DatabaseSales();
  final DatabaseProducts databaseProducts = DatabaseProducts();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'por cumplir':
        return const Color.fromARGB(255, 245, 148, 37).withOpacity(0.95); 
      case 'cancelado':
        return Colors.red.withOpacity(0.85);
      case 'completado':
        return const Color.fromARGB(255, 103, 255, 43);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Future<String?> _getProductName(String productId) async {
    return productId.isNotEmpty ? await databaseProducts.getProductName(productId) : 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: databaseSales.getsales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial de ventas'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay historial de ventas disponible'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                // Formatear la fecha
                String formattedDate = '';
                if (data['date'] is Timestamp) {
                  Timestamp timestamp = data['date'];
                  final DateFormat formatter = DateFormat('dd/MM/yyyy');
                  formattedDate = formatter.format(timestamp.toDate());
                } else {
                  formattedDate = data['date'] ?? 'Fecha no disponible';
                }

                // Obtener el color del estado
                String status = data['status'] ?? 'Desconocido';
                Color statusColor = _getStatusColor(status);

                // Obtener el nombre del producto
                return FutureBuilder<String?>(
                  future: _getProductName(data['product_id'] ?? ''),
                  builder: (context, productSnapshot) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: statusColor, // Aplicar color de fondo según el estado
                      child: ListTile(
                        title: Text('Producto: ${productSnapshot.data ?? "Desconocido"}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${data['amout'] ?? 0}'),
                            Text('Estado: $status'),
                            Text('Fecha: $formattedDate'),
                          ],
                        ),
                        trailing: Text('\$${data['subtotal'] ?? 0}'),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
