import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseProducts {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  // Constructor que inicializa la referencia de la colección
  DatabaseProducts() {
    collectionReference = firebaseFirestore.collection('Products');
  }

  // Método para insertar un nuevo usuario en la colección
  Future<void> insertProduct(Map<String, dynamic> product) async {
    return collectionReference!.doc().set(product);
  }

  // Método para eliminar un usuario específico por su ID
  Future<void> deleteProduct(String productId) async {
    return collectionReference!.doc(productId).delete();
  }

  // Método para actualizar un usuario específico por su ID
  Future<void> updateProduct(Map<String, dynamic> product, String productId) async {
    return collectionReference!.doc(productId).update(product);
  }

  //Metodo que obtiene todos los productos 
   Stream<QuerySnapshot> getProducts() {
    return collectionReference!.snapshots();
  }

  // Método para obtener el nombre del producto a partir de su ID
  Future<String?> getProductName(String productId) async {
    DocumentSnapshot doc = await collectionReference!.doc(productId).get();
    if (doc.exists) {
      return doc['product']; 
    }
    return null; 
  }

    // Método para obtener todas las categorías
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      QuerySnapshot snapshot = await firebaseFirestore.collection('categories').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('Products') // Cambia a la colección correcta si es necesario
          .where('category_id', isEqualTo: categoryId) // Asegúrate de que este campo exista
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener productos por categoría: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }
}