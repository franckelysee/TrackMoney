// firebase_service.dart
import 'package:flutter/foundation.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/firebase_wrapper.dart';

/// Service pour interagir avec Firebase
class FirebaseService {
  // Instance du wrapper Firebase
  static final FirebaseWrapper _wrapper = FirebaseWrapper();

  // Initialiser Firebase
  static Future<bool> initializeFirebase() async {
    return await _wrapper.initialize();
  }

  // Vérifier si Firebase est initialisé
  static bool get isInitialized => _wrapper.isInitialized;

  // Authentification

  // Inscription avec email et mot de passe
  static Future<bool> registerWithEmailAndPassword(
      String email, String password) async {
    return await _wrapper.registerWithEmailAndPassword(email, password);
  }

  // Connexion avec email et mot de passe
  static Future<bool> signInWithEmailAndPassword(
      String email, String password) async {
    return await _wrapper.signInWithEmailAndPassword(email, password);
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _wrapper.signOut();
  }

  // Récupérer l'utilisateur actuel
  static String? getCurrentUser() {
    return null; // Utiliser le stockage local à la place
  }

  // Vérifier si l'utilisateur est connecté
  static bool isUserLoggedIn() {
    return false; // Utiliser le stockage local à la place
  }

  // Réinitialiser le mot de passe
  static Future<void> resetPassword(String email) async {
    await _wrapper.resetPassword(email);
  }

  // Mettre à jour le profil utilisateur
  static Future<void> updateUserProfile(String displayName, String? photoURL) async {
    // Utiliser le stockage local à la place
    debugPrint("Mise à jour du profil utilisateur: $displayName");
  }

  // Firestore

  // Créer un document utilisateur dans Firestore
  static Future<void> createUserDocument(UserModel user, String uid) async {
    await _wrapper.createUserDocument(user, uid);
  }

  // Récupérer les données utilisateur depuis Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    return await _wrapper.getUserData(uid);
  }

  // Mettre à jour les données utilisateur dans Firestore
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    // Utiliser le stockage local à la place
    debugPrint("Mise à jour des données utilisateur pour $uid");
  }

  // Synchronisation des données

  // Synchroniser les comptes
  static Future<void> syncAccounts(String uid, List<Map<String, dynamic>> accounts) async {
    // Utiliser le stockage local à la place
    debugPrint("Synchronisation des comptes pour $uid");
  }

  // Synchroniser les transactions
  static Future<void> syncTransactions(String uid, List<Map<String, dynamic>> transactions) async {
    // Utiliser le stockage local à la place
    debugPrint("Synchronisation des transactions pour $uid");
  }
}
