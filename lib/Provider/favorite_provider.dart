import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/services/user_service.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    _auth.authStateChanges().listen((user) {
      // Reload favorites when user changes
      if (user == null) {
        _favoriteIds = [];
      } else {
        loadFavorites();
      }
      notifyListeners();
    });
  }

  // Toggle favorite state
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId, userId); // Remove from favorites
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId, userId); // Add to favorites
    }
    notifyListeners();
  }

  // Check if a product is favorited
  bool isExist(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  // add favorites to firestore
  Future<void> _addFavorite(String productId, String userId) async {
    try {
      await _firestore
          .collection("userFavorite")
          .doc(
              "${userId}_$productId") // Unique document ID based on user and product
          .set({
        'userId': userId,
        'productId': productId,
        'isFavorite': true,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Remove favorite from firestore
  Future<void> _removeFavorite(String productId, String userId) async {
    try {
      await _firestore
          .collection("userFavorite")
          .doc("${userId}_$productId")
          .delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // load favories from firestore (store favorite or not)
  Future<void> loadFavorites() async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      QuerySnapshot snapshot = await _firestore
          .collection("userFavorite")
          .where('userId', isEqualTo: userId)
          .get();

      _favoriteIds =
          snapshot.docs.map((doc) => doc['productId'] as String).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
