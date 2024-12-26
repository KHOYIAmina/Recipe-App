import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

Future<bool> isUser(String userId) async {
  try {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    return docSnapshot.exists; // Returns true if the document exists, otherwise false
  } catch (e) {
    // Handle any potential errors, optionally log them
    throw Exception('Error checking user existence: $e');
  }
}

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Add book to favorites
  Future<void> addRecipeToFavorites(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([recipeId])
      });
    }
  }

  // Remove book from favorites
  Future<void> removeRecipeFromFavorites(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([recipeId])
      });
    }
  }

  // Get favorite books
  Future<List<String>> getFavoriteRecipes() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      return List<String>.from(snapshot.data()?['favorites'] ?? []);
    }
    return [];
  }
}
