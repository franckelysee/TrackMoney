import 'package:flutter/material.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/auth_required_modal.dart';
import 'package:trackmoney/utils/app_config.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:trackmoney/utils/user_utils.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isGuest = false;
  bool isLoading = false;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuestUser();
    _loadThemeMode();
  }

  // Vérifier si l'utilisateur est un visiteur
  Future<void> _checkIfGuestUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      isGuest = await UserUtils.isGuestUser();

      if (isGuest && mounted) {
        _showGuestUserModal();
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut de l\'utilisateur: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Afficher le modal pour les utilisateurs visiteurs
  Future<void> _showGuestUserModal() async {
    final result = await AuthRequiredModal.show(
      context,
      title: 'Paramètres limités',
      message: 'Certains paramètres ne sont pas disponibles pour les utilisateurs visiteurs. Connectez-vous ou créez un compte pour accéder à toutes les fonctionnalités.',
    );

    // Si l'utilisateur a cliqué sur "Annuler", revenir à la page précédente
    if (result != true && mounted) {
      Navigator.pop(context);
    }
  }

  // Charger le mode thème actuel
  void _loadThemeMode() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      isDarkMode = themeProvider.themeData.brightness == Brightness.dark;
    });
  }

  // Changer le mot de passe
  Future<void> _showChangePasswordDialog() async {
    if (isGuest) {
      _showGuestUserModal();
      return;
    }

    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isChanging = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Modifier le mot de passe'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mot de passe actuel
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe actuel',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe actuel';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Nouveau mot de passe
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nouveau mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Confirmation du nouveau mot de passe
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != newPasswordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isChanging
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isChanging = true;
                            });

                            // Ici, vous implémenteriez la logique de changement de mot de passe
                            // Pour l'instant, nous simulons juste un délai
                            await Future.delayed(Duration(seconds: 1));

                            if (mounted) {
                              Navigator.pop(context);

                              // Afficher un message de succès
                              SnackbarNotifier.show(
                                context: context,
                                message: 'Mot de passe modifié avec succès',
                                type: 'success',
                              );
                            }
                          }
                        },
                  child: isChanging
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Modifier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Sécurité
                  _buildSectionTitle('Sécurité', Icons.security, theme),
                  SizedBox(height: 16),
                  _buildSettingCard(
                    title: 'Modifier le mot de passe',
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    onTap: _showChangePasswordDialog,
                    theme: theme,
                  ),
                  SizedBox(height: 24),

                  // Section Apparence
                  _buildSectionTitle('Apparence', Icons.palette_outlined, theme),
                  SizedBox(height: 16),
                  _buildThemeToggleCard(theme),
                ],
              ),
            ),
    );
  }

  // Construire un titre de section
  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // Construire une carte de paramètre
  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Function() onTap,
    required ThemeData theme,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire la carte de bascule de thème
  Widget _buildThemeToggleCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.purple,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Mode sombre',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Switch(
              value: isDarkMode,
              activeColor: theme.colorScheme.primary,
              onChanged: (value) {
                // Basculer le thème
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

                // Mettre à jour l'état local
                setState(() {
                  this.isDarkMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
