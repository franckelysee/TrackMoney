// account_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/user_model.dart';

class AccountService {
  static const String _boxName = 'accounts';

  // Ouvrir la boîte de comptes
  static Future<Box<AccountModel>> _openBox() async {
    return await Hive.openBox<AccountModel>(_boxName);
  }

  // Ajouter un compte
  static Future<void> addAccount(AccountModel account) async {
    final box = await _openBox();
    await box.put(account.id, account);
  }

  // Récupérer tous les comptes
  static Future<List<AccountModel>> getAllAccounts() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer tous les comptes d'un utilisateur
  static Future<List<AccountModel>> getAccountsByUserId(String userId) async {
    final box = await _openBox();
    return box.values.where((account) => account.userId == userId).toList();
  }

  // Récupérer tous les comptes de l'utilisateur actuel
  static Future<List<AccountModel>> getCurrentUserAccounts() async {
    final box = await _openBox();
    final usersBox = await Hive.openBox<UserModel>('users');
    final currentUsers = usersBox.values.where((user) => user.isLoggedIn).toList();

    if (currentUsers.isEmpty) {
      return [];
    }

    final currentUser = currentUsers.first;
    return box.values.where((account) => account.userId == currentUser.id).toList();
  }

  // Récupérer un compte par son ID
  static Future<AccountModel?> getAccountById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  // Mettre à jour un compte
  static Future<void> updateAccount(AccountModel account) async {
    final box = await _openBox();
    await box.put(account.id, account);
  }

  // Supprimer un compte
  static Future<void> deleteAccount(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Récupérer les comptes par type
  static Future<List<AccountModel>> getAccountsByType(String type) async {
    final box = await _openBox();
    return box.values.where((account) => account.type == type).toList();
  }

  // Mettre à jour le solde d'un compte
  static Future<void> updateAccountBalance(String id, double newBalance) async {
    final box = await _openBox();
    final account = box.get(id);
    if (account != null) {
      account.balance = newBalance;
      await box.put(id, account);
    }
  }

  // Ajouter un montant au solde d'un compte
  static Future<void> addToAccountBalance(String id, double amount) async {
    final box = await _openBox();
    final account = box.get(id);
    if (account != null) {
      account.balance = (account.balance ?? 0) + amount;
      await box.put(id, account);
    }
  }

  // Soustraire un montant du solde d'un compte
  static Future<void> subtractFromAccountBalance(String id, double amount) async {
    final box = await _openBox();
    final account = box.get(id);
    if (account != null) {
      account.balance = (account.balance ?? 0) - amount;
      await box.put(id, account);
    }
  }

  // Vérifier si un compte existe
  static Future<bool> accountExists(String name) async {
    final box = await _openBox();
    return box.values.any((account) => account.name?.toLowerCase() == name.toLowerCase());
  }

  // Supprimer tous les comptes
  static Future<void> deleteAllAccounts() async {
    final box = await _openBox();
    await box.clear();
  }
}
