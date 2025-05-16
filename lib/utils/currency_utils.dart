// currency_utils.dart
import 'package:trackmoney/models/divise_model.dart';
import 'package:trackmoney/services/currency_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/utils/user_utils.dart';

/// Classe utilitaire pour les opérations liées aux devises
class CurrencyUtils {
  /// Devise par défaut à utiliser si aucune devise n'est définie
  static const String DEFAULT_CURRENCY = 'FCFA';
  
  /// Cache pour la devise actuelle
  static String? _currentCurrency;
  
  /// Obtenir la devise de l'utilisateur actuel
  static Future<String> getUserCurrency() async {
    // Si la devise est déjà en cache, la retourner
    if (_currentCurrency != null) {
      return _currentCurrency!;
    }
    
    try {
      // Récupérer l'utilisateur actuel
      final currentUser = await UserService.getCurrentUser();
      
      // Si l'utilisateur existe et a une devise par défaut, la retourner
      if (currentUser != null && currentUser.defaultCurrency != null && currentUser.defaultCurrency!.isNotEmpty) {
        _currentCurrency = currentUser.defaultCurrency;
        return _currentCurrency!;
      }
      
      // Sinon, retourner la devise par défaut
      return DEFAULT_CURRENCY;
    } catch (e) {
      // En cas d'erreur, retourner la devise par défaut
      return DEFAULT_CURRENCY;
    }
  }
  
  /// Obtenir le symbole de la devise de l'utilisateur actuel
  static Future<String> getUserCurrencySymbol() async {
    try {
      // Récupérer le code de la devise
      final currencyCode = await getUserCurrency();
      
      // Récupérer la devise
      final currency = await CurrencyService.getCurrencyByCode(currencyCode);
      
      // Si la devise existe et a un symbole, le retourner
      if (currency != null && currency.symbol.isNotEmpty) {
        return currency.symbol;
      }
      
      // Sinon, retourner le code de la devise
      return currencyCode;
    } catch (e) {
      // En cas d'erreur, retourner le code de la devise
      return await getUserCurrency();
    }
  }
  
  /// Formater un montant avec la devise de l'utilisateur actuel
  static Future<String> formatAmount(double amount, {bool showSign = false, bool showCurrency = true}) async {
    final currency = await getUserCurrency();
    final sign = showSign && amount > 0 ? '+' : '';
    
    if (showCurrency) {
      return '$sign${amount.toStringAsFixed(0)} $currency';
    } else {
      return '$sign${amount.toStringAsFixed(0)}';
    }
  }
  
  /// Effacer le cache de la devise actuelle
  static void clearCache() {
    _currentCurrency = null;
  }
}
