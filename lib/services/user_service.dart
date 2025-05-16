// user_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/user_model.dart';

class UserService {
  static const String _boxName = 'users';

  // Ouvrir la boîte d'utilisateurs
  static Future<Box<UserModel>> _openBox() async {
    return await Hive.openBox<UserModel>(_boxName);
  }

  // Ajouter un utilisateur
  static Future<void> addUser(UserModel user) async {
    final box = await _openBox();
    await box.put(user.id, user);
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

  // Connecter un utilisateur
  static Future<bool> loginUser(String email, String password) async {
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

  // Créer un utilisateur visiteur (non connecté)
  static Future<UserModel> createGuestUser() async {
    final box = await _openBox();
    
    // Vérifier s'il existe déjà un utilisateur visiteur
    final guestUsers = box.values.where((user) => 
      user.username == 'Visiteur' && user.email == 'guest@trackmoney.app'
    ).toList();
    
    if (guestUsers.isNotEmpty) {
      return guestUsers.first;
    }
    
    // Créer un nouvel utilisateur visiteur
    final guestUser = UserModel(
      username: 'Visiteur',
      email: 'guest@trackmoney.app',
      defaultCurrency: 'FCFA',
      isLoggedIn: false,
    );
    
    await box.put(guestUser.id, guestUser);
    return guestUser;
  }
}
