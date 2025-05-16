import 'package:flutter/material.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';

/// Modal qui s'affiche lorsqu'un utilisateur visiteur tente d'accéder à une fonctionnalité
/// qui nécessite une authentification.
class AuthRequiredModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onCancel;

  const AuthRequiredModal({
    Key? key,
    this.title = 'Authentification requise',
    this.message = 'Vous devez vous connecter ou créer un compte pour accéder à cette fonctionnalité.',
    this.onCancel,
  }) : super(key: key);

  /// Afficher le modal
  static Future<bool?> show(BuildContext context, {
    String title = 'Authentification requise',
    String message = 'Vous devez vous connecter ou créer un compte pour accéder à cette fonctionnalité.',
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AuthRequiredModal(
        title: title,
        message: message,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ),
            SizedBox(height: 20),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Boutons
            Row(
              children: [
                // Bouton Annuler
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      foregroundColor: isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      if (onCancel != null) onCancel!();
                    },
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Bouton Se connecter
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.push(context, createRoute(AuthPage()));
                    },
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
