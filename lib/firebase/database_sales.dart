 import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSales {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  DatabaseSales() {
    collectionReference = firebaseFirestore.collection('sales');
  }

  // Método para obtener todas las categorías como un Stream de QuerySnapshot
  Stream<QuerySnapshot> getsales() {
    return collectionReference!.snapshots();
  }

  Future<void> insertCategory(Map<String, dynamic> sale) async {
    return collectionReference!.doc().set(sale);
  }

  // Método para eliminar un usuario específico por su ID
  Future<void> deleteCategory(String saleId) async {
    return collectionReference!.doc(saleId).delete();
  }

  // Método para actualizar un usuario específico por su ID
  Future<void> updateCategory(Map<String, dynamic> sale, String saleId) async {
    return collectionReference!.doc(saleId).update(sale);
  }

  Stream<List<Map<String, dynamic>>> getSalesByStatus(String status) {
    return collectionReference!
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}

 
 