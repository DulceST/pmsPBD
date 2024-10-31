import 'package:flutter/material.dart';
import 'package:pmspbd/firebase/database_products.dart';
import 'package:pmspbd/firebase/database_sales.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesScreen extends StatelessWidget {
  final DatabaseSales databaseSales = DatabaseSales();
  final DatabaseProducts databaseProducts = DatabaseProducts();

  Future<String?> _getProductName(String productId) async {
    return productId.isNotEmpty ? await databaseProducts.getProductName(productId) : 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _registerSale(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: databaseSales.getSalesByStatus('por cumplir'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ventas pendientes.'));
          }

          return ListView(
            children: snapshot.data!.map((sale) {
              return FutureBuilder<String?>(
                future: _getProductName(sale['product_id'] ?? ''),
                builder: (context, productSnapshot) {
                  return ListTile(
                    title: Text('Producto: ${productSnapshot.data ?? "Desconocido"}'),
                    subtitle: Text('Cliente: ${sale['client'] ?? "Desconocido"}'),
                    onTap: () => _showSaleDetails(context, sale),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${sale['subtotal'] ?? 0}'),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelSale(sale['id']), // Pasar el ID del documento
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

    Future<void> _cancelSale(String saleId) async {
    try {
      await databaseSales.updateSaleStatus(saleId, 'cancelado');
    } catch (e) {
      print('Error al cancelar la venta: $e');
    }
  }

  Future<void> _showSaleDetails(BuildContext context, Map<String, dynamic> sale) async {
    String? productName = await _getProductName(sale['product_id'] ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles de la Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: $productName'),
              Text('Cliente: ${sale['client'] ?? "Desconocido"}'),
              Text('Cantidad: ${sale['amout'] ?? 0}'),
              Text('Subtotal: \$${sale['subtotal'] ?? 0}'),
              Text('Estado: ${sale['status']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                await databaseSales.updateSaleStatus(sale['id'], 'completado');
                Navigator.pop(context);
              },
              child: const Text('Marcar como Completada'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerSale(BuildContext context) async {
    final TextEditingController clientController = TextEditingController();
    String? selectedCategoryId;
    String? selectedProductId; // This will store the product ID
    int quantity = 1;
    double price = 0;
    double subtotal = 0;

    List<Map<String, String>> categories = await _getCategories();
    Map<String, Map<String, dynamic>> products = {}; // Changed to hold product ID, name, and price

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Registrar Venta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: clientController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Cliente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: const Text('Seleccionar Categoría'),
                    value: selectedCategoryId,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name']!),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      selectedCategoryId = value;
                      products = await _getProductsByCategoryId(selectedCategoryId!);
                      setState(() {}); // Refresh dialog with loaded products
                    },
                  ),
                  const SizedBox(height: 10),
                  if (products.isNotEmpty)
                    DropdownButton<String>(
                      hint: const Text('Seleccionar Producto'),
                      value: selectedProductId,
                      items: products.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key, // Use the product ID as value
                          child: Text(entry.value['name']), // Show the product name
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProductId = value; // Set the product ID
                          price = products[value]!['price']; // Get the price
                          subtotal = price * quantity;

                          // Debugging: Print the selected product ID
                          print('Selected Product ID: $selectedProductId');
                        });
                      },
                    ),
                  const SizedBox(height: 10),
                  if (selectedProductId != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cantidad:'),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                                subtotal = price * quantity;
                              });
                            }
                          },
                        ),
                        Text(quantity.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              subtotal = price * quantity;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (selectedProductId != null)
                    Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (clientController.text.isNotEmpty && selectedProductId != null) {
                      // Debugging: Print the selected product before inserting
                      print('Inserting Sale with Product ID: $selectedProductId');

                      databaseSales.insertsale({
                        'client': clientController.text,
                        'product_id': selectedProductId,
                        'amout': quantity,
                        'subtotal': subtotal,
                        'status': 'por cumplir',
                        'date': DateTime.now()
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, String>>> _getCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['category'] as String,
      };
    }).toList();
  }

  Future<Map<String, Map<String, dynamic>>> _getProductsByCategoryId(String categoryId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Products')
        .where('category_id', isEqualTo: categoryId)
        .get();
    return {
      for (var doc in snapshot.docs) doc.id: {'name': doc['product'], 'price': doc['price']} // Store ID, name, and price
    };
  }
}
