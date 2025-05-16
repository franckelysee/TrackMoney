// database_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/divise_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/currency_service.dart';
import 'package:trackmoney/services/user_service.dart';

class DatabaseService {
  // Initialisation de Hive
  static Future<void> initHive() async {
    await Hive.initFlutter(); // Initialisation de Hive avec Flutter

    // Enregistrer les adaptateurs
    Hive.registerAdapter(NotificationModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(DeviseAdapter());

    // Ouvrir les boîtes
    await Hive.openBox<NotificationModel>('notifications');
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<AccountModel>('accounts');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<Devise>('currencies');
    await Hive.openBox('appSettings');

    // Initialiser les données par défaut
    await _initDefaultData();
  }

  // Initialiser les données par défaut
  static Future<void> _initDefaultData() async {
    // Initialiser les devises par défaut
    await CurrencyService.initDefaultCurrencies();

    // Créer un utilisateur visiteur par défaut si aucun utilisateur n'existe
    final users = await UserService.getAllUsers();
    if (users.isEmpty) {
      await UserService.createGuestUser();
    }
  }

  // Fermer toutes les boîtes
  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  // Supprimer toutes les données
  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk('notifications');
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.deleteBoxFromDisk('categories');
    await Hive.deleteBoxFromDisk('accounts');
    await Hive.deleteBoxFromDisk('appSettings');
  }
}
