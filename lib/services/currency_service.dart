// currency_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/divise_model.dart';

class CurrencyService {
  static const String _boxName = 'currencies';

  // Ouvrir la boîte des devises
  static Future<Box<Devise>> _openBox() async {
    return await Hive.openBox<Devise>(_boxName);
  }

  // Ajouter une devise
  static Future<void> addCurrency(Devise currency) async {
    final box = await _openBox();
    await box.put(currency.devise, currency);
  }

  // Récupérer toutes les devises
  static Future<List<Devise>> getAllCurrencies() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer une devise par son code
  static Future<Devise?> getCurrencyByCode(String code) async {
    final box = await _openBox();
    return box.get(code);
  }

  // Mettre à jour une devise
  static Future<void> updateCurrency(Devise currency) async {
    final box = await _openBox();
    await box.put(currency.devise, currency);
  }

  // Supprimer une devise
  static Future<void> deleteCurrency(String code) async {
    final box = await _openBox();
    await box.delete(code);
  }

  // Vérifier si une devise existe
  static Future<bool> currencyExists(String code) async {
    final box = await _openBox();
    return box.containsKey(code);
  }

  // Initialiser les devises par défaut
  static Future<void> initDefaultCurrencies() async {
    final box = await _openBox();

    // Vérifier si la boîte est vide
    if (box.isEmpty) {
      // Liste des devises par défaut avec leurs symboles
      final defaultCurrencies = [
        Devise(name: 'Franc CFA', devise: 'FCFA', symbol: 'FCFA'),
        Devise(name: 'Euro', devise: 'EUR', symbol: '€'),
        Devise(name: 'Dollar américain', devise: 'USD', symbol: '\$'),
        Devise(name: 'Livre sterling', devise: 'GBP', symbol: '£'),
        Devise(name: 'Yen japonais', devise: 'JPY', symbol: '¥'),
        Devise(name: 'Franc suisse', devise: 'CHF', symbol: 'CHF'),
        Devise(name: 'Dollar canadien', devise: 'CAD', symbol: 'CA\$'),
        Devise(name: 'Dollar australien', devise: 'AUD', symbol: 'A\$'),
        Devise(name: 'Yuan chinois', devise: 'CNY', symbol: '¥'),
        Devise(name: 'Naira nigérian', devise: 'NGN', symbol: '₦'),
        Devise(name: 'Rand sud-africain', devise: 'ZAR', symbol: 'R'),
        Devise(name: 'Dirham marocain', devise: 'MAD', symbol: 'DH'),
        Devise(name: 'Dinar tunisien', devise: 'TND', symbol: 'DT'),
        Devise(name: 'Cedi ghanéen', devise: 'GHS', symbol: '₵'),
      ];

      // Ajouter les devises par défaut
      for (var currency in defaultCurrencies) {
        await box.put(currency.devise, currency);
      }
    }
  }
}
