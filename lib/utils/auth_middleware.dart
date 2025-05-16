// auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/utils/user_utils.dart';

/// Middleware pour vérifier l'authentification des utilisateurs
class AuthMiddleware {
  /// Vérifie si un utilisateur est connecté (visiteur ou utilisateur normal)
  /// Si aucun utilisateur n'est connecté, redirige vers la page d'authentification
  /// Retourne true si un utilisateur est connecté, false sinon
  static Future<bool> checkAuth(BuildContext context) async {
    // Vérifier s'il y a un utilisateur connecté
    final currentUser = await UserService.getCurrentUser();
    
    if (currentUser == null) {
      // Si aucun utilisateur n'est connecté, créer un utilisateur visiteur
      final guestUser = await UserService.createGuestUser();
      
      if (guestUser.id != null) {
        // L'utilisateur visiteur a été créé et connecté
        return true;
      } else {
        // Échec de création de l'utilisateur visiteur, rediriger vers la page d'authentification
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false,
          );
        }
        return false;
      }
    }
    
    // Un utilisateur est connecté (visiteur ou normal)
    return true;
  }
  
  /// Vérifie si l'utilisateur actuel est un visiteur
  /// Retourne true si l'utilisateur est un visiteur, false sinon
  static Future<bool> isGuestUser() async {
    return await UserUtils.isGuestUser();
  }
}
