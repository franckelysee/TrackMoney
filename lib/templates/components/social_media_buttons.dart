import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMediaButtons extends StatelessWidget {
  final Function()? onFacebookPressed;
  final Function()? onGooglePressed;

  const SocialMediaButtons({
    super.key,
    this.onFacebookPressed,
    this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Se connecter avec',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton Facebook
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3b5998).withAlpha(isDarkMode ? 50 : 100),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onFacebookPressed ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3b5998), // Couleur de Facebook
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Facebook',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Bouton Google
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(isDarkMode ? 50 : 100),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onGooglePressed ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Couleur de Google
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
