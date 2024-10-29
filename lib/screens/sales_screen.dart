import 'package:flutter/material.dart';
import 'package:pmspbd/firebase/database_products.dart';
import 'package:pmspbd/firebase/database_sales.dart';


class SalesScreen extends StatelessWidget {
  final DatabaseSales databaseSales = DatabaseSales();
  final DatabaseProducts databaseProducts = DatabaseProducts();

  Future<String?> _getProductName(String productId) async {
    if (productId.isNotEmpty) {
      // Verificar que el productId no esté vacío
      return await databaseProducts.getProductName(productId);
    }
    return null; // Retorna null si el productId es vacío
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Pendientes'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: databaseSales
            .getSalesByStatus('por cumplir'), // Obtener ventas por cumplir
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Mostrar indicador de carga
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
                    'No hay ventas pendientes.')); // Mensaje si no hay datos
          }

          // Mostrar lista de ventas pendientes
          return FutureBuilder<List<Widget>>(
            future: Future.wait(snapshot.data!.map((sale) async {
              String? productName = await _getProductName(sale['product_id'] ??
                  ''); // Obtener el nombre del producto, con manejo de null
              return ListTile(
                title: Text(
                    'Producto: ${productName ?? "Desconocido"}'), // Mostrar nombre del producto
                subtitle: Text(
                    'Cliente: ${sale['client'] ?? "Desconocido"}'), // Información adicional
                trailing: Text('\$${sale['subtotal'] ?? 0}'), // Precio subtotal
              );
            }).toList()),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Mostrar indicador de carga
              }

              if (futureSnapshot.hasData) {
                return ListView(
                  children: futureSnapshot.data!,
                );
              } else {
                return const Center(
                    child: Text(
                        'No hay productos disponibles.')); // Mensaje en caso de que no haya datos
              }
            },
          );
        },
      ),
    );
  }
}
