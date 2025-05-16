// user_service.dart
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/firebase_options.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/firebase_service.dart';

class UserService {
  static const String _boxName = 'users';
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static bool _firebaseInitialized = false;

  // Initialiser Firebase si ce n'est pas déjà fait
  static Future<void> _ensureFirebaseInitialized() async {
    if (!_firebaseInitialized) {
      try {
        // Vérifier si Firebase est déjà initialisé
        Firebase.app();
        _firebaseInitialized = true;
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        debugPrint("Firebase déjà initialisé");
      } catch (e) {
        // Si Firebase n'est pas initialisé, l'initialiser
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          _firebaseInitialized = true;
          _auth = FirebaseAuth.instance;
          _firestore = FirebaseFirestore.instance;
          debugPrint("Firebase initialisé avec succès");
        } catch (e) {
          debugPrint("Erreur lors de l'initialisation de Firebase dans UserService: $e");
          _firebaseInitialized = false;
          _auth = null;
          _firestore = null;
        }
      }
    }
  }

  // Obtenir l'instance de FirebaseAuth
  static Future<FirebaseAuth?> get auth async {
    await _ensureFirebaseInitialized();
    return _auth;
  }

  // Obtenir l'instance de FirebaseFirestore
  static Future<FirebaseFirestore?> get firestore async {
    await _ensureFirebaseInitialized();
    return _firestore;
  }

  // Ouvrir la boîte d'utilisateurs
  static Future<Box<UserModel>> _openBox() async {
    return await Hive.openBox<UserModel>(_boxName);
  }

  // Ajouter un utilisateur avec Firebase
  static Future<UserModel?> addUser(UserModel user) async {
    try {
      // S'assurer que Firebase est initialisé
      final auth = await UserService.auth;
      final firestore = await UserService.firestore;

      // Si Firebase n'est pas disponible, utiliser le stockage local
      if (auth == null || firestore == null) {
        return _addUserLocally(user);
      }

      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );

      if (userCredential.user != null) {
        // Créer un nouvel utilisateur avec l'UID Firebase
        final firebaseUser = UserModel(
          id: userCredential.user!.uid,
          username: user.username,
          email: user.email,
          password: user.password,
          birthDate: user.birthDate,
          country: user.country,
          city: user.city,
          defaultCurrency: user.defaultCurrency,
          profileImagePath: user.profileImagePath,
          coverImagePath: user.coverImagePath,
          isLoggedIn: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Créer le document utilisateur dans Firestore
        await firestore.collection('users').doc(firebaseUser.id).set({
          'username': firebaseUser.username,
          'email': firebaseUser.email,
          'birthDate': firebaseUser.birthDate?.millisecondsSinceEpoch,
          'country': firebaseUser.country,
          'city': firebaseUser.city,
          'defaultCurrency': firebaseUser.defaultCurrency,
          'profileImagePath': firebaseUser.profileImagePath,
          'coverImagePath': firebaseUser.coverImagePath,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Enregistrer l'utilisateur localement
        final box = await _openBox();

        // Déconnecter tous les autres utilisateurs
        for (var existingUser in box.values) {
          if (existingUser.isLoggedIn) {
            existingUser.isLoggedIn = false;
            await box.put(existingUser.id, existingUser);
          }
        }

        await box.put(firebaseUser.id, firebaseUser);
        return firebaseUser;
      }

      return null;
    } catch (e) {
      // Fallback: créer l'utilisateur localement si Firebase échoue
      return _addUserLocally(user);
    }
  }

  // Méthode d'ajout d'utilisateur locale (fallback)
  static Future<UserModel?> _addUserLocally(UserModel user) async {
    try {
      final box = await _openBox();

      // Déconnecter tous les autres utilisateurs
      for (var existingUser in box.values) {
        if (existingUser.isLoggedIn) {
          existingUser.isLoggedIn = false;
          await box.put(existingUser.id, existingUser);
        }
      }

      // Marquer le nouvel utilisateur comme connecté
      user.isLoggedIn = true;
      user.createdAt = DateTime.now();
      user.updatedAt = DateTime.now();

      await box.put(user.id, user);
      return user;
    } catch (e) {
      debugPrint('Erreur d\'ajout d\'utilisateur local: $e');
      return null;
    }
  }

  // Récupérer tous les utilisateurs
  static Future<List<UserModel>> getAllUsers() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer un utilisateur par son ID
  static Future<UserModel?> getUserById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  // Récupérer l'utilisateur actuel (connecté)
  static Future<UserModel?> getCurrentUser() async {
    final box = await _openBox();
    final users = box.values.where((user) => user.isLoggedIn).toList();
    return users.isNotEmpty ? users.first : null;
  }

  // Récupérer un utilisateur par email
  static Future<UserModel?> getUserByEmail(String email) async {
    final box = await _openBox();
    final users = box.values.where((user) => user.email == email).toList();
    return users.isNotEmpty ? users.first : null;
  }

  // Mettre à jour un utilisateur
  static Future<void> updateUser(UserModel user) async {
    final box = await _openBox();
    await box.put(user.id, user);
  }

  // Supprimer un utilisateur
  static Future<void> deleteUser(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Connecter un utilisateur avec Firebase
  static Future<bool> loginUser(String email, String password) async {
    try {
      // S'assurer que Firebase est initialisé
      final auth = await UserService.auth;
      final firestore = await UserService.firestore;

      // Si Firebase n'est pas disponible, utiliser le stockage local
      if (auth == null || firestore == null) {
        return _loginUserLocally(email, password);
      }

      // Tentative de connexion avec Firebase
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Récupérer les données utilisateur depuis Firestore
        final docSnapshot = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        // Si l'utilisateur existe dans Firestore
        if (docSnapshot.exists) {
          final userData = docSnapshot.data()!;

          // Mettre à jour ou créer l'utilisateur local
          final box = await _openBox();

          // Déconnecter tous les autres utilisateurs locaux
          for (var user in box.values) {
            if (user.isLoggedIn) {
              user.isLoggedIn = false;
              await box.put(user.id, user);
            }
          }

          // Vérifier si l'utilisateur existe déjà localement
          final localUsers = box.values.where((user) => user.email == email).toList();
          UserModel localUser;

          if (localUsers.isNotEmpty) {
            // Mettre à jour l'utilisateur existant
            localUser = localUsers.first;
            localUser.isLoggedIn = true;
            localUser.username = userData['username'] ?? localUser.username;
            localUser.defaultCurrency = userData['defaultCurrency'] ?? localUser.defaultCurrency;
            localUser.country = userData['country'] ?? localUser.country;
            localUser.city = userData['city'] ?? localUser.city;
            localUser.profileImagePath = userData['profileImagePath'] ?? localUser.profileImagePath;
            localUser.coverImagePath = userData['coverImagePath'] ?? localUser.coverImagePath;
            localUser.updatedAt = DateTime.now();
          } else {
            // Créer un nouvel utilisateur local
            localUser = UserModel(
              id: userCredential.user!.uid,
              username: userData['username'] ?? email.split('@')[0],
              email: email,
              password: password, // Stocker le mot de passe localement pour la compatibilité
              defaultCurrency: userData['defaultCurrency'],
              country: userData['country'],
              city: userData['city'],
              profileImagePath: userData['profileImagePath'],
              coverImagePath: userData['coverImagePath'],
              isLoggedIn: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }

          await box.put(localUser.id, localUser);
          return true;
        } else {
          // L'utilisateur existe dans Firebase Auth mais pas dans Firestore
          // Créer un document utilisateur dans Firestore
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'username': email.split('@')[0],
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Créer l'utilisateur local
          final box = await _openBox();

          // Déconnecter tous les autres utilisateurs
          for (var user in box.values) {
            if (user.isLoggedIn) {
              user.isLoggedIn = false;
              await box.put(user.id, user);
            }
          }

          final localUser = UserModel(
            id: userCredential.user!.uid,
            username: email.split('@')[0],
            email: email,
            password: password,
            isLoggedIn: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await box.put(localUser.id, localUser);
          return true;
        }
      }

      return false;
    } catch (e) {
      // Fallback: essayer la connexion locale si Firebase échoue
      return _loginUserLocally(email, password);
    }
  }

  // Méthode de connexion locale (fallback)
  static Future<bool> _loginUserLocally(String email, String password) async {
    final box = await _openBox();
    final users = box.values.where((user) =>
      user.email == email && user.password == password
    ).toList();

    if (users.isNotEmpty) {
      // Déconnecter tous les autres utilisateurs
      for (var user in box.values) {
        if (user.isLoggedIn) {
          user.isLoggedIn = false;
          await box.put(user.id, user);
        }
      }

      // Connecter l'utilisateur
      final user = users.first;
      user.isLoggedIn = true;
      await box.put(user.id, user);
      return true;
    }

    return false;
  }

  // Déconnecter l'utilisateur actuel
  static Future<void> logoutCurrentUser() async {
    try {
      // S'assurer que Firebase est initialisé
      final auth = await UserService.auth;

      // Déconnexion de Firebase si disponible
      if (auth != null) {
        await auth.signOut();
      }
    } catch (e) {
      // Ignorer les erreurs de déconnexion Firebase
    }

    // Déconnexion locale
    final box = await _openBox();
    final users = box.values.where((user) => user.isLoggedIn).toList();

    for (var user in users) {
      user.isLoggedIn = false;
      await box.put(user.id, user);
    }
  }

  // Vérifier si un email existe déjà
  static Future<bool> emailExists(String email) async {
    final box = await _openBox();
    return box.values.any((user) => user.email == email);
  }

  // Vérifier si un nom d'utilisateur existe déjà
  static Future<bool> usernameExists(String username) async {
    final box = await _openBox();
    return box.values.any((user) => user.username == username);
  }

  // Mettre à jour la devise par défaut
  static Future<void> updateDefaultCurrency(String userId, String currency) async {
    final box = await _openBox();
    final user = box.get(userId);
    if (user != null) {
      user.defaultCurrency = currency;
      await box.put(userId, user);
    }
  }

  // Créer un utilisateur visiteur (connecté)
  static Future<UserModel> createGuestUser() async {
    final box = await _openBox();

    // Déconnecter tous les autres utilisateurs
    for (var user in box.values) {
      if (user.isLoggedIn) {
        user.isLoggedIn = false;
        await box.put(user.id, user);
      }
    }

    // Vérifier s'il existe déjà un utilisateur visiteur
    final guestUsers = box.values.where((user) =>
      user.username == 'Visiteur' && user.email == 'guest@trackmoney.app'
    ).toList();

    if (guestUsers.isNotEmpty) {
      // Connecter l'utilisateur visiteur existant
      final guestUser = guestUsers.first;
      guestUser.isLoggedIn = true;
      await box.put(guestUser.id, guestUser);
      return guestUser;
    }

    // Créer un nouvel utilisateur visiteur
    final guestUser = UserModel(
      username: 'Visiteur',
      email: 'guest@trackmoney.app',
      defaultCurrency: 'FCFA',
      isLoggedIn: true, // Marquer comme connecté
    );

    await box.put(guestUser.id, guestUser);
    return guestUser;
  }
}
