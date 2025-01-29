// database.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';

class Database {
  // Initialisation de Hive
  static Future<void> initHive() async {
    await Hive.initFlutter(); // Initialisation de Hive avec Flutter
    Hive.registerAdapter(
        NotificationModelAdapter()); // Enregistrer l'adaptateur
    await Hive.openBox<NotificationModel>(
        'notifications'); // Ouvrir la boîte de notifications

    // transaction (ajouter page)
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(
        'transactions'); // Ouvrir la boîte de transactions

    // category (categorypage)
    Hive.registerAdapter(CategoryModelAdapter());
    await Hive.openBox<CategoryModel>(
        'categories'); // Ouvrir la boîte de categories

    // compte (comptepage)
    Hive.registerAdapter(AccountModelAdapter());
    await Hive.openBox<AccountModel>('accounts'); // Ouvrir la boîte de comptes
  }

  // Vérifier si c'est la première ouverture de l'application
  static Future<bool> isFirstLaunch() async {
    final box = await Hive.openBox('appSettings');
    return box.get('isFirstLaunch',
        defaultValue: true); // Si c'est la première ouverture
  }

  // Mettre à jour l'indicateur de la première ouverture
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final box = await Hive.openBox('appSettings');
    await box.put('isFirstLaunch', isFirstLaunch);
  }

  // Ajouter une Transaction

  static Future<void> addTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(transaction.id, transaction);
  }

  // Récupérer toutes les transactions
  static Future<List<TransactionModel>> getAllTransactions() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    return box.values.toList();
  }

  // Supprimer une transaction
  static Future<void> deleteTransaction(int id) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.delete(id);
  }

  // Ajouter une catégorie
  static Future<void> addCategory(CategoryModel category) async {
    final box = await Hive.openBox<CategoryModel>('categories');
    await box.put(category.id, category);
  }

  // Récupérer toutes les catégories
  static Future<List<CategoryModel>> getAllCategories() async {
    final box = await Hive.openBox<CategoryModel>('categories');
    return box.values.toList();
  }

  // Supprimer une catégorie
  static Future<void> deleteCategory(int id) async {
    final box = await Hive.openBox<CategoryModel>('categories');
    await box.delete(id);
  }
  // --------------------------------------------------------------
  // Ajouter un compte
  static Future<void> addAccount(AccountModel account) async {
    final box = await Hive.openBox<AccountModel>('accounts');
    await box.put(account.id, account);
  }

  // Récupérer tous les comptes
  static Future<List<AccountModel>> getAllAccounts() async {
    final box = await Hive.openBox<AccountModel>('accounts');
    return box.values.toList();
  }

  // Supprimer un compte
  static Future<void> deleteAccount(int id) async {
    final box = await Hive.openBox<AccountModel>('accounts');
    await box.delete(id);
  }


  // modifier le prix du compte 
  static Future<void> updateAccount(AccountModel account) async {
    final box = await Hive.openBox<AccountModel>('accounts');
    await box.put(account.id, account);
  }

  // add notification 
  static Future<void> addNotification(NotificationModel notification) async {
    final box = await Hive.openBox<NotificationModel>('notifications');
    await box.put(notification.id, notification);
  }

  // get all notifications
  static Future<List<NotificationModel>> getAllNotifications() async {
    final box = await Hive.openBox<NotificationModel>('notifications');
    return box.values.toList();
  }

  // delete notification
  static Future<void> deleteNotification(String id) async {
    final box = await Hive.openBox<NotificationModel>('notifications');
    await box.delete(id);
  }

  
}
