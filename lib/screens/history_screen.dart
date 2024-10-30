import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmspbd/firebase/database_sales.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseSales databaseSales = DatabaseSales();

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
                  formattedDate = '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
                } else {
                  formattedDate = data['date'] ?? 'Fecha no disponible';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(data['product'] ?? 'Producto desconocido'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${data['amout'] ?? 0}'),
                        Text('Estado: ${data['status'] ?? 'Desconocido'}'),
                        Text('Fecha: $formattedDate'), // Mostrar la fecha
                      ],
                    ),
                    trailing: Text('\$${data['subtotal'] ?? 0}'),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
