import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseUsers {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  DatabaseUsers() {
    collectionReference = firebaseFirestore.collection('users');
  }

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

  // Método para obtener los datos del usuario autenticado
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await collectionReference!.doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?; // Devuelve los datos del usuario
    }
    return null; // Devuelve null si no hay usuario
  }

}
