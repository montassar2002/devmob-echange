import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Ajouter un objet
  Future<void> addItem(Item item) async {
    try {
      print('🔵 Ajout objet dans Firestore...');
      await _firestore.collection('items').add(item.toJson());
      print('✅ Objet ajouté !');
    } catch (e) {
      print('❌ Erreur ajout objet : $e');
      rethrow;
    }
  }

  // Supprimer un objet
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  // Mettre à jour un objet
  Future<void> updateItem(Item item) async {
    await _firestore
        .collection('items')
        .doc(item.id)
        .update(item.toJson());
  }
}