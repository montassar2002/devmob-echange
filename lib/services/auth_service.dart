import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Utilisateur connecté actuellement
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // CONNEXION
  Future<app.UserModel?> signIn(String email, String password) async {
    try {
      print('🔵 Début connexion...');
      
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ Connexion réussie : ${result.user!.uid}');

      // Récupérer les données utilisateur depuis Firestore
      final doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (doc.exists) {
        print('✅ Données utilisateur récupérées !');
        return app.UserModel.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      print('⚠️ Utilisateur trouvé mais pas de données dans Firestore');
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Auth connexion : ${e.code} - ${e.message}');
      throw _handleAuthError(e);
    } catch (e) {
      print('❌ Erreur générale connexion : $e');
      throw 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // INSCRIPTION
  Future<app.UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required app.UserRole role,
  }) async {
    try {
      print('🔵 Début inscription...');

      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ Utilisateur créé : ${result.user!.uid}');

      // Créer le profil dans Firestore
      final user = app.UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      print('🔵 Sauvegarde dans Firestore...');

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());

      print('✅ Données sauvegardées dans Firestore !');

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Auth inscription : ${e.code} - ${e.message}');
      throw _handleAuthError(e);
    } catch (e) {
      print('❌ Erreur générale inscription : $e');
      throw 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // DÉCONNEXION
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion : $e');
    }
  }

  // Récupérer les données utilisateur
  Future<app.UserModel?> getUserData(String uid) async {
    try {
      print('🔵 Récupération données utilisateur : $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print('✅ Données trouvées !');
        return app.UserModel.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      print('⚠️ Aucune donnée trouvée pour : $uid');
      return null;
    } catch (e) {
      print('❌ Erreur récupération données : $e');
      return null;
    }
  }

  // Gestion des erreurs Firebase
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (min. 6 caractères).';
      case 'invalid-email':
        return 'Email invalide.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Une erreur est survenue : ${e.code}';
    }
  }
}