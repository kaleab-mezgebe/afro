import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  static final CollectionReference favoritesCollection = FirebaseFirestore.instance.collection('users');

  static Future<void> addToFavorites(String userId, Map<String, dynamic> provider) async {
    try {
      await favoritesCollection
          .doc(userId)
          .collection('favorites')
          .add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            ...provider,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  static Future<void> removeFromFavorites(String userId, String favoriteId) async {
    try {
      await favoritesCollection
          .doc(userId)
          .collection('favorites')
          .doc(favoriteId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    try {
      final snapshot = await favoritesCollection
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  static Future<void> updateFavorites(String userId, List<Map<String, dynamic>> favorites) async {
    try {
      await favoritesCollection
          .doc(userId)
          .collection('favorites')
          .doc('user_favorites')
          .set({
            'favorites': favorites,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update favorites: $e');
    }
  }
}
