// database.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';

class Database {
  // Initialisation de Hive
  static Future<void> initHive() async {
    await Hive.initFlutter(); // Initialisation de Hive avec Flutter
    Hive.registerAdapter(NotificationModelAdapter()); // Enregistrer l'adaptateur
    await Hive.openBox<NotificationModel>('notifications'); // Ouvrir la boîte de notifications

    // transaction (add)
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>('transactions'); // Ouvrir la boîte de transactions
  }

  // Vérifier si c'est la première ouverture de l'application
  static Future<bool> isFirstLaunch() async {
    final box = await Hive.openBox('appSettings');
    return box.get('isFirstLaunch', defaultValue: true); // Si c'est la première ouverture
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
}
