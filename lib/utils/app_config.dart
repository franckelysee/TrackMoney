import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xffE7F6FF),
    primary: Color(0xFF242760),
    secondary: Color(0xFF000000),
  ),
  cardColor: Color(0xFFFFFFFF),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      surface: Color(0xFF0e0e0e),
      primary: Color(0xFF6E73C4),
      secondary: Color(0xFFF8F8F8)),
  cardColor: Color(0xff272727),
  useMaterial3: true,
);

class AppConfig {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF242760); // Bleu principal
  static const Color bgColor = Color(0xFFFFFFFF); // Couleur de fond (blanc)
  static const Color textColor = Color(0xFF000000); // Couleur du texte (noir)
  static const Color greenbuttonColor =
      Color(0xFF1B7D2A); // Couleur des boutons

  // Styles de texte
  static const TextStyle primaryTextStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    fontWeight: FontWeight.bold,
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
    borderRadius: BorderRadius.circular(30),
  );
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

