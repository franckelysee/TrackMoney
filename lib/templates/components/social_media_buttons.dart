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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Se connecter avec',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onFacebookPressed??() {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b5998), // Couleur de Facebook
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const FaIcon(
                FontAwesomeIcons.facebook,
                color: Colors.white,
              ),
              label: const Text(
                'Facebook',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: onGooglePressed??() {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Couleur de Google
                padding:const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.white,
              ),
              label: const Text(
                'Google',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
