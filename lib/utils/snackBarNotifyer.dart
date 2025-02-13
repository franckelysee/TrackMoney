import 'package:flutter/material.dart';

class SnackbarNotifier {
  static void show({
    required BuildContext context,
    required String message,
    String type = "success",
    int durationInSeconds = 3,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Fermer un snackBar existant avant d'en afficher un nouveau
    scaffoldMessenger.hideCurrentSnackBar();

    // Définir la couleur selon le type
    Color backgroundColor;
    switch (type) {
      case "error":
        backgroundColor = Colors.red;
        break;
      case "warning":
        backgroundColor = Colors.orange;
        break;
      case "info":
        backgroundColor = Colors.blue;
        break;
      default:
        backgroundColor = Colors.green;
    }

    // Afficher le SnackBar
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: Duration(seconds: durationInSeconds),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating, // Pour un affichage plus esthétique
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
