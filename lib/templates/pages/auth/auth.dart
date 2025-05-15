import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/components/social_media_buttons.dart';
import 'package:trackmoney/templates/pages/screens/devise.dart';
import 'package:trackmoney/utils/devise_list.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Simuler une logique d'inscription ou de connexion
  // void _handleAuthentication() async {
  //   // Logique d'inscription ou de connexion ici
  //   // Par exemple, après l'inscription ou la connexion réussie :

  //   // Une fois l'utilisateur authentifié, mettre à jour l'indicateur "isFirstLaunch"
  //   await Database.setFirstLaunch(false); // Marquer que ce n'est plus le premier lancement

  //   // Naviguer vers la HomePage
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomePage()),
  //   );
  // }
  @override
  void initState() {
    super.initState();
    setFirstLaunch();
  }

  setFirstLaunch() async {
    await Database.setFirstLaunch(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            // Logo et slogan
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo avec effet d'ombre
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Nom de l'application
                      Text(
                        'TrackMoney',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Slogan
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(isDarkMode ? 40 : 30),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "'Parce que chaque dépense a son importance.'",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Boutons d'authentification
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton d'inscription
                    Container(
                      width: double.infinity,
                      height: 56,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(isDarkMode ? 50 : 100),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: (){}, // À implémenter
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Bouton de connexion
                    Container(
                      width: double.infinity,
                      height: 56,
                      margin: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: (){}, // À implémenter
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? theme.colorScheme.surfaceContainerHighest
                              : Colors.white,
                          foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Boutons de médias sociaux
                    SocialMediaButtons(
                      onFacebookPressed: null,
                      onGooglePressed: null,
                    ),
                  ],
                ),
              ),
              // Lien pour continuer sans compte
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(createRoute(DeviseSelector(
                      devises: devises,
                    )));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: primaryColor.withAlpha(isDarkMode ? 40 : 20),
                  ),
                  child: Text(
                    "Continuer sans créer de compte",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}
