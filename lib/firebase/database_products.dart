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

  
}