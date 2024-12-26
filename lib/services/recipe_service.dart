import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get list of all Recipes
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final snapshot = await _firestore.collection('recipe-app').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get details of a specific Recipe
  Future<Map<String, dynamic>?> getRecipeDetails(String recipeId) async {
    final doc = await _firestore.collection('recipe-app').doc(recipeId).get();
    return doc.data();
  }
}
