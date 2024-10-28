import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseCategories {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  DatabaseCategories() {
    collectionReference = firebaseFirestore.collection('categories');
  }

  // Método para obtener todas las categorías como un Stream de QuerySnapshot
  Stream<QuerySnapshot> getCategories() {
    return collectionReference!.snapshots();
  }

  Future<void> insertCategory(Map<String, dynamic> category) async {
    return collectionReference!.doc().set(category);
  }

  // Método para eliminar un usuario específico por su ID
  Future<void> deleteCategory(String categoryId) async {
    return collectionReference!.doc(categoryId).delete();
  }

  // Método para actualizar un usuario específico por su ID
  Future<void> updateCategory(Map<String, dynamic> category, String categoryId) async {
    return collectionReference!.doc(categoryId).update(category);
  }
}
