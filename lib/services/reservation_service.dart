import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une réservation
  Future<void> createReservation(Reservation reservation) async {
    try {
      print('🔵 Création réservation...');
      await _firestore.collection('reservations').add(reservation.toJson());
      print('✅ Réservation créée !');
    } catch (e) {
      print('❌ Erreur création réservation : $e');
      rethrow;
    }
  }

  // Réservations du locataire
  Stream<List<Reservation>> getRenterReservations(String renterId) {
    return _firestore
        .collection('reservations')
        .where('renterId', isEqualTo: renterId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    });
  }

  // Réservations du propriétaire
  Stream<List<Reservation>> getOwnerReservations(String ownerId) {
    return _firestore
        .collection('reservations')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    });
  }

  // Accepter une réservation
  Future<void> acceptReservation(String reservationId) async {
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': 'accepted'});
  }

  // Refuser une réservation
  Future<void> rejectReservation(String reservationId) async {
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': 'rejected'});
  }

  // Terminer une réservation
  Future<void> completeReservation(String reservationId) async {
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': 'completed'});
  }
}