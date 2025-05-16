import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/user_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/services/account_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/sync_button.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/templates/pages/screens/profile/edit_profile.dart';
import 'package:trackmoney/utils/user_utils.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Color btnTecxtColor = Colors.white;
  UserModel? currentUser;
  List<AccountModel> userAccounts = [];
  double totalBalance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Vérifier si l'utilisateur est un visiteur après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfGuestUser();
    });
  }

  // Vérifier si l'utilisateur est un visiteur et afficher le modal si nécessaire
  Future<void> _checkIfGuestUser() async {
    // Utiliser la fonction utilitaire pour afficher le modal si l'utilisateur est un visiteur
    final isGuest = await UserUtils.showAuthModalIfGuest(context);

    // Si l'utilisateur est un visiteur et que le modal a été affiché, revenir à la page précédente
    // sauf si l'utilisateur a cliqué sur "Se connecter" (result == true)
    if (isGuest && mounted) {
      Navigator.pop(context);
    }
  }

  // Charger les données de l'utilisateur
  Future<void> _loadUserData() async {
    try {
      // Récupérer l'utilisateur actuel
      currentUser = await UserService.getCurrentUser();
      
      // Si aucun utilisateur n'est connecté, créer un utilisateur visiteur
      currentUser ??= await UserService.createGuestUser();

      // Récupérer les comptes de l'utilisateur
      userAccounts = await AccountService.getAccountsByUserId(currentUser!.id!);

      // Calculer le solde total
      totalBalance = userAccounts.fold(0, (sum, account) => sum + (account.balance ?? 0));

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Afficher un message d'erreur discret
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible de charger les données utilisateur"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Afficher la boîte de dialogue de confirmation de déconnexion
  void _showLogoutConfirmationDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Se déconnecter"),
        content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Annuler",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Se déconnecter"),
          ),
        ],
      ),
    );
  }

  // Gérer la déconnexion
  Future<void> _handleLogout() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Déconnecter l'utilisateur
      await UserService.logoutCurrentUser();

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Rediriger vers la page d'authentification
        Navigator.pushAndRemoveUntil(
          context,
          createRoute(AuthPage()),
          (route) => false, // Supprimer toutes les routes précédentes
        );

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vous avez été déconnecté avec succès"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Une erreur est survenue lors de la déconnexion"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
      ),
      body: isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          )
        : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background image with gradient overlay
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
                // Profile picture with animated border
                Container(
                  alignment: Alignment.center,
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(128),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Container(
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
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Nom et Description
                  Column(
                    children: [
                      Text(
                        currentUser?.username ?? "Utilisateur",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? "Aucun email",
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Adresse et email
                  Container(
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
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Adresse
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
                                FontAwesomeIcons.mapLocation,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Adresse",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${currentUser?.city ?? 'Non défini'}, ${currentUser?.country ?? 'Non défini'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Divider(height: 32),

                        // Email
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
                                Icons.email,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "E-mail",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    currentUser?.email ?? "Aucun email",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Solde total sur tous les comptes disponible
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withAlpha(200),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(60),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "SOLDE TOTAL",
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${totalBalance.toStringAsFixed(0)} ${currentUser?.defaultCurrency ?? 'FCFA'}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Titre de la section
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
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
                          "Mes Comptes",
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

                  // Cartes de compte
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    child: userAccounts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Aucun compte disponible",
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: userAccounts.length > 3 ? 3 : userAccounts.length,
                          itemBuilder: (context, index) {
                            // Différentes couleurs pour chaque carte
                            List<Color> cardColors = [
                              Color(0xFF6C63FF),  // Violet
                              Color(0xFF4CAF50),  // Vert
                              Color(0xFFFFA726),  // Orange
                            ];

                            final account = userAccounts[index];

                            // Déterminer l'icône en fonction du type de compte
                            IconData accountIcon;
                            if (account.type?.toLowerCase().contains('banc') ?? false) {
                              accountIcon = Icons.account_balance;
                            } else if (account.type?.toLowerCase().contains('epargne') ?? false) {
                              accountIcon = Icons.savings;
                            } else if (account.type?.toLowerCase().contains('mobile') ?? false) {
                              accountIcon = Icons.phone_android;
                            } else {
                              accountIcon = Icons.account_balance_wallet;
                            }

                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.black26
                                        : Colors.grey.withAlpha(40),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark
                                      ? cardColors[index % 3].withAlpha(100)
                                      : cardColors[index % 3].withAlpha(50),
                                  width: 1,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.brightness == Brightness.dark
                                            ? cardColors[index % 3].withAlpha(50)
                                            : cardColors[index % 3].withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        accountIcon,
                                        color: cardColors[index % 3],
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "${account.balance?.toStringAsFixed(0) ?? '0'} ${account.currencyCode ?? 'FCFA'}",
                                      style: TextStyle(
                                        color: cardColors[index % 3],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      account.name ?? "Compte",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 55,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(EditeProfile(user: currentUser))
                        ).then((_) {
                          // Recharger les données de l'utilisateur après la modification
                          _loadUserData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: theme.colorScheme.primary.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Modifier le Profil",
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

                  // Bouton de synchronisation
                  Container(
                    width: double.infinity,
                    height: 55,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: SyncButton(
                      onSyncComplete: () {
                        // Recharger les données après la synchronisation
                        _loadUserData();
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Bouton de déconnexion
                  Container(
                    width: double.infinity,
                    height: 55,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.dark
                            ? theme.colorScheme.errorContainer
                            : Color(0xFFFFEBEE),
                        foregroundColor: theme.colorScheme.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: theme.colorScheme.error.withAlpha(50),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Se déconnecter",
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
                  SizedBox(height: 30),

                ],
              ),
            )
          ],
        ),
      ),

    );
  }
}