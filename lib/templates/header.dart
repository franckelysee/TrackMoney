import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/pages/screens/profile/profile.dart';
import 'package:trackmoney/utils/user_utils.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final String? subtitle;


  const AppHeader({super.key, required this.title, this.subtitle});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Color.fromRGBO(0, 0, 0, isDarkMode ? 0.3 : 0.1),
      surfaceTintColor: Colors.transparent,
      leading: null,
      foregroundColor: theme.colorScheme.primary,
      backgroundColor: isDarkMode
          ? theme.colorScheme.surfaceContainerLow
          : Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
        ]
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(12),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Icon(
              FontAwesomeIcons.circleUser,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(12),
              elevation: 0,
            ),
            onPressed: () async {
              // Vérifier si l'utilisateur est un visiteur
              final isGuest = await UserUtils.showAuthModalIfGuest(context);

              // Si l'utilisateur n'est pas un visiteur, naviguer vers la page de profil
              if (!isGuest && mounted) {
                Navigator.push(context, createRoute(Profile()));
              }
            },
          ),
        )
      ],
    );
  }
}
