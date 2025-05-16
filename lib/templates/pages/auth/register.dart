import 'package:flutter/material.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/services/currency_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/pages/screens/devise.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Fonction pour gérer l'inscription
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Vérifier si l'email existe déjà
        final emailExists = await UserService.emailExists(emailController.text.trim());
        if (emailExists) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            SnackbarNotifier.show(
              context: context,
              message: "Cet email est déjà utilisé",
              type: 'error',
            );
          }
          return;
        }

        // Vérifier si le nom d'utilisateur existe déjà
        final usernameExists = await UserService.usernameExists(usernameController.text.trim());
        if (usernameExists) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            SnackbarNotifier.show(
              context: context,
              message: "Ce nom d'utilisateur est déjà utilisé",
              type: 'error',
            );
          }
          return;
        }

        // Créer un nouvel utilisateur
        final newUser = UserModel(
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          isLoggedIn: true, // Connecter automatiquement l'utilisateur après l'inscription
        );

        // Ajouter l'utilisateur à la base de données
        await UserService.addUser(newUser);

        if (mounted) {
          setState(() {
            isLoading = false;
          });

          // Afficher un message de succès
          SnackbarNotifier.show(
            context: context,
            message: "Inscription réussie ! Bienvenue ${newUser.username}",
            type: 'success',
          );

          // Rediriger vers la page de sélection de devise
          final devises = await CurrencyService.getAllCurrencies();
          Navigator.pushReplacement(
            context,
            createRoute(DeviseSelector(
              devises: devises,
              userId: newUser.id,
            )),
          );
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
                    "Inscription",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Créez un compte pour commencer à suivre vos finances",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Champ nom d'utilisateur
                  CustomTextFormField(
                    controller: usernameController,
                    labelText: "Nom d'utilisateur",
                    hintText: "Entrez votre nom d'utilisateur",
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d'utilisateur";
                      }
                      if (value.length < 3) {
                        return "Le nom d'utilisateur doit contenir au moins 3 caractères";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

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
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Champ confirmation mot de passe
                  CustomTextFormField(
                    controller: confirmPasswordController,
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Confirmez votre mot de passe',
                    prefixIcon: Icons.lock_outline,
                    isPassword: obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),

                  // Bouton d'inscription
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
                      onPressed: isLoading ? null : _handleRegister,
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
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Lien vers la page de connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous avez déjà un compte ?",
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Se connecter",
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