import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/firebase_options.dart'; // Ce fichier sera généré par FlutterFire CLI

class FirebaseService {
  // Instances Firebase
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialiser Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Authentification
  
  // Inscription avec email et mot de passe
  static Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Connexion avec email et mot de passe
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer l'utilisateur actuel
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Vérifier si l'utilisateur est connecté
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Réinitialiser le mot de passe
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Mettre à jour le profil utilisateur
  static Future<void> updateUserProfile(String displayName, String? photoURL) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firestore

  // Créer un document utilisateur dans Firestore
  static Future<void> createUserDocument(UserModel user, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'username': user.username,
        'email': user.email,
        'defaultCurrency': user.defaultCurrency,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la création du document utilisateur: $e');
    }
  }

  // Récupérer les données utilisateur depuis Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données utilisateur: $e');
    }
  }

  // Mettre à jour les données utilisateur dans Firestore
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des données utilisateur: $e');
    }
  }

  // Synchronisation des données

  // Synchroniser les comptes
  static Future<void> syncAccounts(String uid, List<Map<String, dynamic>> accounts) async {
    try {
      // Créer une référence à la collection des comptes de l'utilisateur
      CollectionReference accountsRef = _firestore.collection('users').doc(uid).collection('accounts');
      
      // Utiliser une transaction pour garantir l'intégrité des données
      await _firestore.runTransaction((transaction) async {
        // Récupérer tous les comptes existants
        QuerySnapshot existingAccounts = await accountsRef.get();
        
        // Supprimer tous les comptes existants
        for (DocumentSnapshot doc in existingAccounts.docs) {
          transaction.delete(doc.reference);
        }
        
        // Ajouter les nouveaux comptes
        for (Map<String, dynamic> account in accounts) {
          DocumentReference docRef = accountsRef.doc(account['id']);
          transaction.set(docRef, {
            ...account,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Erreur lors de la synchronisation des comptes: $e');
    }
  }

  // Synchroniser les transactions
  static Future<void> syncTransactions(String uid, List<Map<String, dynamic>> transactions) async {
    try {
      // Créer une référence à la collection des transactions de l'utilisateur
      CollectionReference transactionsRef = _firestore.collection('users').doc(uid).collection('transactions');
      
      // Utiliser une transaction pour garantir l'intégrité des données
      await _firestore.runTransaction((transaction) async {
        // Récupérer toutes les transactions existantes
        QuerySnapshot existingTransactions = await transactionsRef.get();
        
        // Supprimer toutes les transactions existantes
        for (DocumentSnapshot doc in existingTransactions.docs) {
          transaction.delete(doc.reference);
        }
        
        // Ajouter les nouvelles transactions
        for (Map<String, dynamic> transactionData in transactions) {
          DocumentReference docRef = transactionsRef.doc(transactionData['id']);
          transaction.set(docRef, {
            ...transactionData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Erreur lors de la synchronisation des transactions: $e');
    }
  }

  // Gestion des erreurs d'authentification
  static Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Aucun utilisateur trouvé avec cet email.');
      case 'wrong-password':
        return Exception('Mot de passe incorrect.');
      case 'email-already-in-use':
        return Exception('Cet email est déjà utilisé par un autre compte.');
      case 'weak-password':
        return Exception('Le mot de passe est trop faible.');
      case 'invalid-email':
        return Exception('L\'adresse email est invalide.');
      case 'operation-not-allowed':
        return Exception('Cette opération n\'est pas autorisée.');
      case 'user-disabled':
        return Exception('Ce compte utilisateur a été désactivé.');
      case 'too-many-requests':
        return Exception('Trop de tentatives. Veuillez réessayer plus tard.');
      default:
        return Exception('Une erreur s\'est produite: ${e.message}');
    }
  }
}
