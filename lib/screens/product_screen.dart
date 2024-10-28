import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pmspbd/firebase/database_categories.dart';
import 'package:pmspbd/firebase/database_products.dart';

class ProductScreen extends StatefulWidget {
  ProductScreen({super.key});
  final DatabaseProducts databaseProducts = DatabaseProducts();
  final DatabaseCategories databaseCategories =
      DatabaseCategories(); // Crear instancia de DatabaseCategories

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.databaseProducts.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar productos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData =
                  products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              return ListTile(
                title: Text(productData['product'] ?? 'Producto sin nombre'),
                subtitle: Text(productData['description'] ?? 'Sin descripción'),
                trailing: Text(productData['price'] != null
                    ? '\$${productData['price']}'
                    : 'Sin precio'),
                onTap: () =>
                    _showEditProductDialog(context, productData, productId),
              );
            },
          );
        },
      ),
      floatingActionButton: ExpandableFab(
        key: _key,
        children: [
          FloatingActionButton.small(
            heroTag: "btn1",
            onPressed: () {
              _showInsertProductDialog(context);
            },
            child: const Icon(Icons.app_registration),
          ),
          FloatingActionButton.small(
            heroTag: "btn2",
            onPressed: () {
              _showInsertCategory(context);
            },
            child: const Icon(Icons.category_rounded),
          )
        ],
      ),
    );
  }

//Metodo para mostrar el Dialog y editar el producto
  void _showEditProductDialog(BuildContext context,
      Map<String, dynamic> productData, String productId) {
    final TextEditingController productController =
        TextEditingController(text: productData['product']);
    final TextEditingController descriptionController =
        TextEditingController(text: productData['description']);
    final TextEditingController stockController =
        TextEditingController(text: productData['stock']?.toString());
    final TextEditingController priceController =
        TextEditingController(text: productData['price']?.toString());

    String selectedCategoryId =
        productData['category_id'] ?? ''; // ID de la categoría seleccionada

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField(productController, 'Nombre', context),
                _buildEditableField(
                    descriptionController, 'Descripción', context),
                _buildEditableField(stockController, 'Stock', context),
                _buildEditableField(priceController, 'Precio', context),

                // StreamBuilder para el ComboBox de categorías
                StreamBuilder<QuerySnapshot>(
                  stream: widget.databaseCategories.getCategories(),
                  builder: (context, categorySnapshot) {
                    if (!categorySnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final categories = categorySnapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedCategoryId.isNotEmpty
                          ? selectedCategoryId
                          : null,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categories.map((category) {
                        final categoryData =
                            category.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: category.id, // ID de la categoría
                          child: Text(
                              categoryData['category'] ?? 'Categoría sin nombre'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value ?? '';
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                await widget.databaseProducts.deleteProduct(productId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                await widget.databaseProducts.updateProduct({
                  'nombre': productController.text,
                  'descripcion': descriptionController.text,
                  'stock': int.tryParse(stockController.text),
                  'precio': double.tryParse(priceController.text),
                  'categoriaId':
                      selectedCategoryId, // Guardar ID de la categoría
                }, productId);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(
      TextEditingController controller, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Metodo para mostrar el Dialog e insertar un producto 
  void _showInsertProductDialog(BuildContext context) {
    final TextEditingController productController =
        TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController();
    final TextEditingController stockController =
        TextEditingController();
    final TextEditingController priceController =
        TextEditingController();

    String selectedCategoryId = ''; // ID de la categoría seleccionada

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField(productController, 'Producto', context),
                _buildEditableField(
                    descriptionController, 'Descripción', context),
                _buildEditableField(stockController, 'Stock', context),
                _buildEditableField(priceController, 'Precio', context),

                // StreamBuilder para el ComboBox de categorías
                StreamBuilder<QuerySnapshot>(
                  stream: widget.databaseCategories.getCategories(),
                  builder: (context, categorySnapshot) {
                    if (!categorySnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final categories = categorySnapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedCategoryId.isNotEmpty
                          ? selectedCategoryId
                          : null,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categories.map((category) {
                        final categoryData =
                            category.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: category.id, // ID de la categoría
                          child: Text(
                              categoryData['category'] ?? 'Categoría sin nombre'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value ?? '';
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {      
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                if (productController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nombre y precio son obligatorios')),
                );
                return;
              }

              try {
                await widget.databaseProducts.insertProduct({
                  'nombre': productController.text,
                  'descripcion': descriptionController.text,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'precio': double.tryParse(priceController.text) ?? 0.0,
                  'categoriaId': selectedCategoryId,
                });
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al guardar el producto')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
          ],
        );
      },
    );
  }

  //Metodo para insertar una nueva categoria 
  void _showInsertCategory(BuildContext context) {
    final TextEditingController categoryController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar categoria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField(categoryController, 'Categoria', context),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {      
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                if (categoryController.text.isEmpty ) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre de la categoria es obligatorio')),
                );
                return;
              }

              try {
                await widget.databaseCategories.insertCategory({
                  'nombre': categoryController.text,
                  
                });
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al guardar categoria')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
          ],
        );
      },
    );
  }
}
