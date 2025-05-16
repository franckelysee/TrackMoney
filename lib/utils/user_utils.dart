// user_utils.dart
import 'package:flutter/material.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/auth_required_modal.dart';

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

    // Si aucun utilisateur n'est connecté, retourner false
    if (currentUser == null) {
      return false;
    }

    // Vérifier si l'utilisateur est un visiteur
    return currentUser.email == 'guest@trackmoney.app' &&
           currentUser.username == 'Visiteur';
  }

  /// Afficher le modal d'authentification si l'utilisateur est un visiteur
  /// Retourne true si l'utilisateur est un visiteur et que le modal a été affiché
  /// Retourne false si l'utilisateur n'est pas un visiteur
  static Future<bool> showAuthModalIfGuest(BuildContext context) async {
    final isGuest = await isGuestUser();

    if (isGuest && context.mounted) {
      // Afficher le modal d'authentification
      await AuthRequiredModal.show(
        context,
        title: 'Profil non disponible',
        message: 'Vous êtes actuellement connecté en tant que visiteur. Connectez-vous ou créez un compte pour accéder à votre profil et synchroniser vos données.',
      );
      return true;
    }

    return false;
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
