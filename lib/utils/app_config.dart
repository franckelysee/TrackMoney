import 'package:flutter/material.dart';

// Palette de couleurs pour le mode clair
const Color _lightPrimary = Color(0xFF2A3990); // Bleu royal plus vif
const Color _lightPrimaryContainer = Color(0xFFE0E6FF); // Bleu très clair pour les conteneurs
const Color _lightSecondary = Color(0xFF4F378B); // Violet pour les accents
const Color _lightSurface = Color(0xFFF8F9FA); // Gris très clair pour le fond
const Color _lightError = Color(0xFFBA1A1A); // Rouge pour les erreurs
const Color _lightSurfaceContainerLow = Color(0xFFEEEFF4); // Gris clair pour les conteneurs de surface
const Color _lightSurfaceContainerHigh = Color(0xFFE4E6F0); // Gris un peu plus foncé
const Color _lightSurfaceContainerHighest = Color(0xFFFFFFFF); // Blanc pour les conteneurs de premier plan

// Palette de couleurs pour le mode sombre
const Color _darkPrimary = Color(0xFF8B93E8); // Bleu clair lumineux
const Color _darkPrimaryContainer = Color(0xFF343B7A); // Bleu foncé pour les conteneurs
const Color _darkSecondary = Color(0xFFCFBCFF); // Violet clair pour les accents
const Color _darkSurface = Color(0xFF1A1C2E); // Bleu très foncé pour le fond
const Color _darkError = Color(0xFFFFB4AB); // Rouge clair pour les erreurs
const Color _darkSurfaceContainerLow = Color(0xFF252738); // Bleu-gris foncé pour les conteneurs de surface
const Color _darkSurfaceContainerHigh = Color(0xFF2D2F42); // Un peu plus clair
const Color _darkSurfaceContainerHighest = Color(0xFF35384D); // Encore plus clair pour les conteneurs de premier plan

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: _lightPrimary,
    primaryContainer: _lightPrimaryContainer,
    secondary: _lightSecondary,
    surface: _lightSurface,
    error: _lightError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    onError: Colors.white,
    surfaceContainerLow: _lightSurfaceContainerLow,
    surfaceContainerHigh: _lightSurfaceContainerHigh,
    surfaceContainerHighest: _lightSurfaceContainerHighest,
  ),
  cardColor: Colors.white,
  scaffoldBackgroundColor: _lightSurface,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightSurface,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightPrimary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _lightPrimary),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: _darkPrimary,
    primaryContainer: _darkPrimaryContainer,
    secondary: _darkSecondary,
    surface: _darkSurface,
    error: _darkError,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.black,
    surfaceContainerLow: _darkSurfaceContainerLow,
    surfaceContainerHigh: _darkSurfaceContainerHigh,
    surfaceContainerHighest: _darkSurfaceContainerHighest,
  ),
  cardColor: _darkSurfaceContainerLow,
  scaffoldBackgroundColor: _darkSurface,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkSurface,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkPrimary,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkPrimary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkSurfaceContainerLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[800]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[800]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _darkPrimary),
    ),
  ),
);

class AppConfig {
  // Couleurs principales - Mode clair
  static const Color primaryColor = _lightPrimary; // Bleu principal
  static const Color primaryContainerColor = _lightPrimaryContainer; // Conteneur bleu clair
  static const Color secondaryColor = _lightSecondary; // Couleur secondaire (violet)
  static const Color surfaceColor = _lightSurface; // Couleur de surface
  static const Color errorColor = _lightError; // Couleur d'erreur

  // Couleurs de conteneurs - Mode clair
  static const Color surfaceContainerLowColor = _lightSurfaceContainerLow;
  static const Color surfaceContainerHighColor = _lightSurfaceContainerHigh;
  static const Color surfaceContainerHighestColor = _lightSurfaceContainerHighest;

  // Couleurs principales - Mode sombre
  static const Color darkPrimaryColor = _darkPrimary; // Bleu clair pour le mode sombre
  static const Color darkPrimaryContainerColor = _darkPrimaryContainer; // Conteneur bleu foncé
  static const Color darkSecondaryColor = _darkSecondary; // Couleur secondaire (violet clair)
  static const Color darkSurfaceColor = _darkSurface; // Couleur de surface sombre

  // Couleurs de conteneurs - Mode sombre
  static const Color darkSurfaceContainerLowColor = _darkSurfaceContainerLow;
  static const Color darkSurfaceContainerHighColor = _darkSurfaceContainerHigh;
  static const Color darkSurfaceContainerHighestColor = _darkSurfaceContainerHighest;

  // Couleurs utilitaires
  static const Color bgColor = _lightSurfaceContainerHighest; // Couleur de fond (blanc)
  static const Color textColor = Color(0xFF000000); // Couleur du texte (noir)
  static const Color greenbuttonColor = Color(0xFF2E7D32); // Vert plus vif pour les boutons

  // Styles de texte - Mode clair
  static const TextStyle primaryTextStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle lightTextStyle = TextStyle(
    fontSize: 15,
    color: Colors.white,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle boldTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bigTextStyle = TextStyle(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Marges et espacements
  static const double defaultPadding = 16.0;

  // Forme des widgets (boutons, cartes, etc.)
  static RoundedRectangleBorder defaultButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  // Ombres
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  static List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}

