// database.dart
// Ce fichier est maintenant un wrapper pour les services spécifiques
// Il est conservé pour la compatibilité avec le code existant
// À terme, il est recommandé d'utiliser directement les services spécifiques

import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/services/account_service.dart';
import 'package:trackmoney/services/app_settings_service.dart';
import 'package:trackmoney/services/category_service.dart';
import 'package:trackmoney/services/database_service.dart';
import 'package:trackmoney/services/notification_service.dart';
import 'package:trackmoney/services/transaction_service.dart';

class Database {
  // Initialisation de Hive
  static Future<void> initHive() async {
    await DatabaseService.initHive();
  }

  // Vérifier si c'est la première ouverture de l'application
  static Future<bool> isFirstLaunch() async {
    return await AppSettingsService.isFirstLaunch();
  }

  // Mettre à jour l'indicateur de la première ouverture
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await AppSettingsService.setFirstLaunch(isFirstLaunch);
  }

  // Ajouter une Transaction
  static Future<void> addTransaction(TransactionModel transaction) async {
    await TransactionService.addTransaction(transaction);
  }

  // Récupérer toutes les transactions
  static Future<List<TransactionModel>> getAllTransactions() async {
    return await TransactionService.getAllTransactions();
  }

  // Supprimer une transaction
  static Future<void> deleteTransaction(int id) async {
    await TransactionService.deleteTransaction(id.toString());
  }

  // Ajouter une catégorie
  static Future<void> addCategory(CategoryModel category) async {
    await CategoryService.addCategory(category);
  }

  // Récupérer toutes les catégories
  static Future<List<CategoryModel>> getAllCategories() async {
    return await CategoryService.getAllCategories();
  }

  // Supprimer une catégorie
  static Future<void> deleteCategory(int id) async {
    await CategoryService.deleteCategory(id.toString());
  }

  // Ajouter un compte
  static Future<void> addAccount(AccountModel account) async {
    await AccountService.addAccount(account);
  }

  // Récupérer tous les comptes
  static Future<List<AccountModel>> getAllAccounts() async {
    return await AccountService.getAllAccounts();
  }

  // Supprimer un compte
  static Future<void> deleteAccount(int id) async {
    await AccountService.deleteAccount(id.toString());
  }

  // Modifier le prix du compte
  static Future<void> updateAccount(AccountModel account) async {
    await AccountService.updateAccount(account);
  }

  // Ajouter une notification
  static Future<void> addNotification(NotificationModel notification) async {
    await NotificationService.addNotification(notification);
  }

  // Récupérer toutes les notifications
  static Future<List<NotificationModel>> getAllNotifications() async {
    return await NotificationService.getAllNotifications();
  }

  // Supprimer une notification
  static Future<void> deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);
  }

  // Marquer une notification comme lue
  static Future<void> markNotification(String id) async {
    await NotificationService.markNotificationAsRead(id);
  }

  // Archiver une notification
  static Future<void> archiveNotification(String id) async {
    await NotificationService.archiveNotification(id);
  }
}
