import 'package:flutter/material.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/auth_required_modal.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/utils/user_utils.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:intl/intl.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Color btnTextColor = Colors.white;
  bool isGuest = false;
  bool isLoading = true;
  UserModel? currentUser;
  bool _formChanged = false;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de formulaire
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController birthDateController;
  late TextEditingController countryController;
  late TextEditingController cityController;
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec des valeurs par défaut
    usernameController = TextEditingController();
    emailController = TextEditingController();
    birthDateController = TextEditingController();
    countryController = TextEditingController();
    cityController = TextEditingController();
    selectedCurrency = 'FCFA';

    // Charger l'utilisateur actuel et vérifier s'il est un visiteur
    _loadCurrentUser();
  }

  // Charger l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Récupérer l'utilisateur actuel
      currentUser = await UserService.getCurrentUser();

      if (currentUser != null) {
        // Initialiser les contrôleurs avec les données de l'utilisateur
        usernameController.text = currentUser!.username ?? '';
        emailController.text = currentUser!.email ?? '';

        // Formater la date de naissance si elle existe
        String birthDateText = '';
        if (currentUser!.birthDate != null) {
          final date = currentUser!.birthDate!;
          birthDateText = DateFormat('dd/MM/yyyy').format(date);
        }
        birthDateController.text = birthDateText;

        countryController.text = currentUser!.country ?? '';
        cityController.text = currentUser!.city ?? '';
        selectedCurrency = currentUser!.defaultCurrency ?? 'FCFA';
      }

      // Vérifier si l'utilisateur est un visiteur
      isGuest = await UserUtils.isGuestUser();

      if (isGuest && mounted) {
        _showGuestUserModal();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'utilisateur: $e');
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
      title: 'Modification non disponible',
      message: 'Vous êtes actuellement connecté en tant que visiteur. Connectez-vous ou créez un compte pour modifier votre profil et synchroniser vos données.',
    );

    // Si l'utilisateur a cliqué sur "Annuler", revenir à la page précédente
    if (result != true && mounted) {
      Navigator.pop(context);
    }
  }

  // Mettre à jour le profil de l'utilisateur
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || currentUser == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Créer un nouvel utilisateur avec les données mises à jour
      final updatedUser = currentUser!.copyWith(
        username: usernameController.text,
        birthDate: birthDateController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(birthDateController.text)
            : null,
        country: countryController.text,
        city: cityController.text,
        defaultCurrency: selectedCurrency,
      );

      // Mettre à jour l'utilisateur
      await UserService.updateUser(updatedUser);

      if (mounted) {
        // Afficher un message de succès
        SnackbarNotifier.show(
          context: context,
          message: "Profil mis à jour avec succès",
          type: 'success',
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');

      if (mounted) {
        // Afficher un message d'erreur
        SnackbarNotifier.show(
          context: context,
          message: "Une erreur est survenue lors de la mise à jour du profil",
          type: 'error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _formChanged = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Libérer les ressources
    usernameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    countryController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // Méthode pour construire un champ de formulaire avec icône et style
  Widget _buildFormField({
    required IconData icon,
    required Color color,
    required Widget child,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? color.withAlpha(50)
                    : color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: child),
          ],
        ),
        if (!isLast) SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(180),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(180),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Modifier le Profil",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Image de couverture avec effet de dégradé
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 80),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(Rect.fromLTRB(0, 150, rect.width, rect.height));
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image(
                          image: AssetImage('assets/images/profile/salon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Bouton pour ajouter la photo de couverture
                    Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        tooltip: "Changer la photo de couverture",
                      ),
                    )
                  ],
                ),
                // Photo de profil avec effet d'ombre
                Container(
                  alignment: Alignment.center,
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(100),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 155,
                        height: 155,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(80),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/profile/avatar.jpeg'),
                        ),
                      ),
                      // Bouton pour modifier la photo de profil
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          tooltip: "Changer la photo de profil",
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(16),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la section
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Informations personnelles",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[200]
                                  : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Conteneur principal du formulaire avec ombre
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.withAlpha(30),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Nom d'utilisateur
                          _buildFormField(
                            icon: Icons.person,
                            color: Color(0xFF6C63FF),
                            child: CustomTextFormField(
                              controller: usernameController,
                              hintText: "Nom d'utilisateur",
                              labelText: "Nom d'utilisateur",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Le nom d'utilisateur est requis";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _formChanged = true;
                                });
                              },
                            ),
                          ),

                          // Email (non modifiable)
                          _buildFormField(
                            icon: Icons.email,
                            color: Color(0xFF4CAF50),
                            child: CustomTextFormField(
                              controller: emailController,
                              hintText: "E-mail",
                              labelText: "E-mail",
                              enabled: false, // Rendre le champ non modifiable
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),

                          // Date de naissance
                          _buildFormField(
                            icon: Icons.cake,
                            color: Color(0xFFE57373),
                            child: CustomTextFormField(
                              controller: birthDateController,
                              hintText: "12/04/2000",
                              labelText: "Date de naissance",
                              onChanged: (value) {
                                setState(() {
                                  _formChanged = true;
                                });
                              },
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  // Afficher le sélecteur de date
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: currentUser?.birthDate ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (picked != null && mounted) {
                                    setState(() {
                                      birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
                                      _formChanged = true;
                                    });
                                  }
                                },
                                icon: Icon(Icons.calendar_month, color: Colors.grey),
                              ),
                            ),
                          ),

                          // Pays
                          _buildFormField(
                            icon: Icons.public,
                            color: Color(0xFF42A5F5),
                            child: CustomTextFormField(
                              controller: countryController,
                              hintText: "Pays",
                              labelText: "Pays",
                              onChanged: (value) {
                                setState(() {
                                  _formChanged = true;
                                });
                              },
                            ),
                          ),

                          // Ville
                          _buildFormField(
                            icon: Icons.location_city,
                            color: Color(0xFF9575CD),
                            child: CustomTextFormField(
                              controller: cityController,
                              hintText: "Ville",
                              labelText: "Ville",
                              onChanged: (value) {
                                setState(() {
                                  _formChanged = true;
                                });
                              },
                            ),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Devise par défaut
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.withAlpha(30),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.primary.withAlpha(50)
                                      : theme.colorScheme.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.attach_money,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                "Devise par défaut",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[200]
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          CustomDropdownButtonFormField(
                            initialValue: selectedCurrency,
                            items: ['FCFA', 'XAF', 'EUR', 'USD', 'GBP'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCurrency = value;
                                  _formChanged = true;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Bouton de mise à jour
                    Container(
                      width: double.infinity,
                      height: 55,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: isGuest || !_formChanged || isLoading
                            ? null // Désactiver le bouton si l'utilisateur est un visiteur ou si aucune modification n'a été faite
                            : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[400],
                          disabledForegroundColor: Colors.grey[700],
                          elevation: 5,
                          shadowColor: theme.colorScheme.primary.withAlpha(100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Mettre à jour",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}