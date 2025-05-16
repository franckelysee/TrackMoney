// sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/account_service.dart';
import 'package:trackmoney/services/transaction_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/utils/user_utils.dart';

/// Service pour gérer la synchronisation des données avec le serveur MySQL
class SyncService {
  // URL de base de l'API
  static const String _baseUrl = 'https://api.trackmoney.com'; // À remplacer par votre URL réelle
  
  // En-têtes HTTP par défaut
  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  /// Vérifier si l'utilisateur est connecté et peut synchroniser
  static Future<bool> canSync() async {
    final currentUser = await UserService.getCurrentUser();
    return currentUser != null && 
           currentUser.isLoggedIn && 
           !await UserUtils.isGuestUser();
  }
  
  /// Authentifier l'utilisateur et obtenir un token
  static Future<String?> authenticate(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _getHeaders(null),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      
      return null;
    } catch (e) {
      print('Erreur d\'authentification: $e');
      return null;
    }
  }
  
  /// Enregistrer un nouvel utilisateur
  static Future<bool> registerUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _getHeaders(null),
        body: jsonEncode(user.toMap()),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Erreur d\'enregistrement: $e');
      return false;
    }
  }
  
  /// Synchroniser les comptes
  static Future<bool> syncAccounts(String token) async {
    try {
      // Récupérer l'utilisateur actuel
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return false;
      
      // Récupérer les comptes locaux
      final localAccounts = await AccountService.getAccountsByUserId(currentUser.id!);
      
      // Envoyer les comptes au serveur
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/sync'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'userId': currentUser.id,
          'accounts': localAccounts.map((account) => account.toMap()).toList(),
        }),
      );
      
      if (response.statusCode == 200) {
        // Récupérer les comptes du serveur
        final data = jsonDecode(response.body);
        final List<dynamic> serverAccounts = data['accounts'];
        
        // Mettre à jour les comptes locaux
        for (var accountData in serverAccounts) {
          final account = AccountModel.fromMap(accountData);
          await AccountService.updateAccount(account);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur de synchronisation des comptes: $e');
      return false;
    }
  }
  
  /// Synchroniser les transactions
  static Future<bool> syncTransactions(String token) async {
    try {
      // Récupérer l'utilisateur actuel
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return false;
      
      // Récupérer les transactions locales
      final localTransactions = await TransactionService.getTransactionsByUserId(currentUser.id!);
      
      // Envoyer les transactions au serveur
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions/sync'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'userId': currentUser.id,
          'transactions': localTransactions.map((transaction) => transaction.toJson()).toList(),
        }),
      );
      
      if (response.statusCode == 200) {
        // Récupérer les transactions du serveur
        final data = jsonDecode(response.body);
        final List<dynamic> serverTransactions = data['transactions'];
        
        // Mettre à jour les transactions locales
        for (var transactionData in serverTransactions) {
          final transaction = TransactionModel.fromJson(transactionData);
          await TransactionService.updateTransaction(transaction);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur de synchronisation des transactions: $e');
      return false;
    }
  }
  
  /// Synchroniser toutes les données
  static Future<bool> syncAll() async {
    try {
      // Vérifier si l'utilisateur peut synchroniser
      if (!await canSync()) return false;
      
      // Authentifier l'utilisateur
      final currentUser = await UserService.getCurrentUser();
      final token = await authenticate(currentUser!.email!, currentUser.password!);
      
      if (token == null) return false;
      
      // Synchroniser les comptes
      final accountsSync = await syncAccounts(token);
      
      // Synchroniser les transactions
      final transactionsSync = await syncTransactions(token);
      
      return accountsSync && transactionsSync;
    } catch (e) {
      print('Erreur de synchronisation: $e');
      return false;
    }
  }
}
