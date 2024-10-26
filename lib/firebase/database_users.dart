import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseUsers {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  // Constructor que inicializa la referencia de la colección
  DatabaseUsers() {
    collectionReference = firebaseFirestore.collection('users');
  }

  // Método para insertar un nuevo usuario en la colección
  Future<void> insertUser(Map<String, dynamic> user) async {
    return collectionReference!.doc().set(user);
  }

  // Método para eliminar un usuario específico por su ID
  Future<void> deleteUser(String userId) async {
    return collectionReference!.doc(userId).delete();
  }

  // Método para actualizar un usuario específico por su ID
  Future<void> updateUser(Map<String, dynamic> user, String userId) async {
    return collectionReference!.doc(userId).update(user);
  }

  
}
