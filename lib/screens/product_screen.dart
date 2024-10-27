import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importación necesaria

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  Stream<QuerySnapshot> _getProducts() {
    return FirebaseFirestore.instance
        .collection('Products')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Contenido principal del cuerpo
      body: StreamBuilder<QuerySnapshot>(
        stream: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los productos"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay productos registrados"));
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
                    title: Text(saleData['product']),
                    subtitle: Text('Descripción: ${saleData['description']}'),
                    trailing: Text('\$${saleData['price']}'), // Añadido símbolo de moneda
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
    );
  }
}
