import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer tous les objets
  Stream<List<Item>> getItems() {
    return _firestore
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Récupérer les objets populaires
  Stream<List<Item>> getPopularItems() {
    return _firestore
        .collection('items')
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Récupérer les objets récents
  Stream<List<Item>> getRecentItems() {
    return _firestore
        .collection('items')
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Rechercher des objets
  Future<List<Item>> searchItems(String query) async {
    final snapshot = await _firestore
        .collection('items')
        .get();

    return snapshot.docs
        .map((doc) => Item.fromJson({'id': doc.id, ...doc.data()}))
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Ajouter un objet AVEC ownerId
  Future<void> addItem(Item item) async {
    try {
      print('🔵 Ajout objet dans Firestore...');
      
      // Récupérer l'utilisateur connecté
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Vous devez être connecté pour ajouter un objet';
      }

      // Ajouter l'ownerId automatiquement
      final itemData = item.toJson();
      itemData['ownerId'] = currentUser.uid;
      
      await _firestore.collection('items').add(itemData);
      print('✅ Objet ajouté avec ownerId: ${currentUser.uid}');
    } catch (e) {
      print('❌ Erreur ajout objet : $e');
      rethrow;
    }
  }

  // Récupérer les objets du propriétaire connecté
  Stream<List<Item>> getOwnerItems(String ownerId) {
    return _firestore
        .collection('items')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Supprimer un objet
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('items').doc(itemId).delete();
      print('✅ Objet supprimé : $itemId');
    } catch (e) {
      print('❌ Erreur suppression : $e');
      rethrow;
    }
  }

  // Mettre à jour un objet
  Future<void> updateItem(Item item) async {
    try {
      await _firestore
          .collection('items')
          .doc(item.id)
          .update(item.toJson());
      print('✅ Objet mis à jour : ${item.id}');
    } catch (e) {
      print('❌ Erreur mise à jour : $e');
      rethrow;
    }
  }
}