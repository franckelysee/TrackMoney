// user_utils.dart
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/user_service.dart';

/// Classe utilitaire pour les opérations liées à l'utilisateur
class UserUtils {
  /// Obtenir l'utilisateur actuel
  static Future<UserModel?> getCurrentUser() async {
    return await UserService.getCurrentUser();
  }
  
  /// Vérifier si un utilisateur est connecté
  static Future<bool> isUserLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null && currentUser.isLoggedIn;
  }
  
  /// Vérifier si l'utilisateur actuel est un visiteur
  static Future<bool> isGuestUser() async {
    final currentUser = await getCurrentUser();
    return currentUser != null && 
           currentUser.email == 'guest@trackmoney.app' && 
           currentUser.username == 'Visiteur';
  }
  
  /// Obtenir l'ID de l'utilisateur actuel ou null si aucun utilisateur n'est connecté
  static Future<String?> getCurrentUserId() async {
    final currentUser = await getCurrentUser();
    return currentUser?.id;
  }
  
  /// Obtenir la devise par défaut de l'utilisateur actuel
  static Future<String> getCurrentUserCurrency() async {
    final currentUser = await getCurrentUser();
    return currentUser?.defaultCurrency ?? 'FCFA';
  }
}
