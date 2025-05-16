// transaction_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/models/user_model.dart';

class TransactionService {
  static const String _boxName = 'transactions';

  // Ouvrir la boîte de transactions
  static Future<Box<TransactionModel>> _openBox() async {
    return await Hive.openBox<TransactionModel>(_boxName);
  }

  // Ajouter une transaction
  static Future<void> addTransaction(TransactionModel transaction) async {
    final box = await _openBox();
    await box.put(transaction.id, transaction);
  }

  // Récupérer toutes les transactions
  static Future<List<TransactionModel>> getAllTransactions() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer toutes les transactions d'un utilisateur
  static Future<List<TransactionModel>> getTransactionsByUserId(String userId) async {
    final box = await _openBox();
    return box.values.where((transaction) => transaction.userId == userId).toList();
  }

  // Récupérer toutes les transactions de l'utilisateur actuel
  static Future<List<TransactionModel>> getCurrentUserTransactions() async {
    final box = await _openBox();
    final usersBox = await Hive.openBox<UserModel>('users');
    final currentUsers = usersBox.values.where((user) => user.isLoggedIn).toList();

    if (currentUsers.isEmpty) {
      return [];
    }

    final currentUser = currentUsers.first;
    return box.values.where((transaction) => transaction.userId == currentUser.id).toList();
  }

  // Récupérer une transaction par son ID
  static Future<TransactionModel?> getTransactionById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  // Mettre à jour une transaction
  static Future<void> updateTransaction(TransactionModel transaction) async {
    final box = await _openBox();
    await box.put(transaction.id, transaction);
  }

  // Supprimer une transaction
  static Future<void> deleteTransaction(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Récupérer les transactions par compte
  static Future<List<TransactionModel>> getTransactionsByAccount(String accountId) async {
    final box = await _openBox();
    return box.values.where((transaction) => transaction.accountId == accountId).toList();
  }

  // Récupérer les transactions par type (revenu ou dépense)
  static Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final box = await _openBox();
    return box.values.where((transaction) => transaction.type == type).toList();
  }

  // Récupérer les transactions par catégorie
  static Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async {
    final box = await _openBox();
    return box.values.where((transaction) => transaction.categoryId == categoryId).toList();
  }

  // Récupérer les transactions par date
  static Future<List<TransactionModel>> getTransactionsByDate(DateTime date) async {
    final box = await _openBox();
    return box.values.where((transaction) {
      return transaction.date.year == date.year &&
             transaction.date.month == date.month &&
             transaction.date.day == date.day;
    }).toList();
  }

  // Récupérer les transactions par mois
  static Future<List<TransactionModel>> getTransactionsByMonth(int year, int month) async {
    final box = await _openBox();
    return box.values.where((transaction) {
      return transaction.date.year == year && transaction.date.month == month;
    }).toList();
  }

  // Récupérer les transactions par année
  static Future<List<TransactionModel>> getTransactionsByYear(int year) async {
    final box = await _openBox();
    return box.values.where((transaction) {
      return transaction.date.year == year;
    }).toList();
  }

  // Récupérer les transactions entre deux dates
  static Future<List<TransactionModel>> getTransactionsBetweenDates(
      DateTime startDate, DateTime endDate) async {
    final box = await _openBox();
    return box.values.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Supprimer toutes les transactions
  static Future<void> deleteAllTransactions() async {
    final box = await _openBox();
    await box.clear();
  }

  // Supprimer les transactions d'un compte
  static Future<void> deleteTransactionsByAccount(String accountId) async {
    final box = await _openBox();
    final keys = box.keys.where((key) => box.get(key)?.accountId == accountId).toList();
    for (var key in keys) {
      await box.delete(key);
    }
  }
}
