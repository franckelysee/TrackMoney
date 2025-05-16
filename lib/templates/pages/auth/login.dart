import 'package:flutter/material.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/services/currency_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/pages/auth/register.dart';
import 'package:trackmoney/templates/pages/screens/devise.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fonction pour gérer la connexion
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Tentative de connexion
        final success = await UserService.loginUser(
          emailController.text.trim(),
          passwordController.text,
        );

        if (mounted) {
          setState(() {
            isLoading = false;
          });

          if (success) {
            // Récupérer l'utilisateur connecté
            final currentUser = await UserService.getCurrentUser();

            // Afficher un message de succès
            SnackbarNotifier.show(
              context: context,
              message: "Connexion réussie ! Bienvenue ${currentUser?.username ?? ''}",
              type: 'success',
            );

            // Rediriger vers la page de sélection de devise si l'utilisateur n'a pas de devise par défaut
            if (currentUser?.defaultCurrency == null || currentUser!.defaultCurrency!.isEmpty) {
              final devises = await CurrencyService.getAllCurrencies();
              Navigator.pushReplacement(
                context,
                createRoute(DeviseSelector(
                  devises: devises,
                  userId: currentUser!.id,
                )),
              );
            } else {
              // Sinon, rediriger vers la page d'accueil
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            // Afficher un message d'erreur
            SnackbarNotifier.show(
              context: context,
              message: "Email ou mot de passe incorrect",
              type: 'error',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });

          // Afficher un message d'erreur
          SnackbarNotifier.show(
            context: context,
            message: "Une erreur est survenue: $e",
            type: 'error',
          );
        }
      }
    }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la page
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bienvenue ! Connectez-vous pour continuer",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Champ email
                  CustomTextFormField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'Entrez votre adresse email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Champ mot de passe
                  CustomTextFormField(
                    controller: passwordController,
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    prefixIcon: Icons.lock_outline,
                    isPassword: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Lien "Mot de passe oublié"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implémenter la récupération de mot de passe
                        SnackbarNotifier.show(
                          context: context,
                          message: "Fonctionnalité à venir",
                          type: 'info',
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Bouton de connexion
                  Container(
                    width: double.infinity,
                    height: 56,
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
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Lien vers la page d'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez pas de compte ?",
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            createRoute(RegisterPage()),
                          );
                        },
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}