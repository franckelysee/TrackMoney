import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/pages/screens/profile/edit_profile.dart';
import 'package:trackmoney/utils/app_config.dart';
import 'dart:ui';


class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Color btnTecxtColor = Colors.white;
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
            color: theme.colorScheme.surface.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                        color: theme.colorScheme.primary.withOpacity(0.5),
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
                        "Mvomo Elysee",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Full-stack Developer",
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
                                    "Mimboman Yaoundé, Cameroun",
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
                                    "franckelysee671@gmail.com",
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
                          "100 000 FCFA",
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
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        // Différentes couleurs pour chaque carte
                        List<Color> cardColors = [
                          Color(0xFF6C63FF),  // Violet
                          Color(0xFF4CAF50),  // Vert
                          Color(0xFFFFA726),  // Orange
                        ];

                        // Différents titres pour chaque carte
                        List<String> cardTitles = [
                          "Compte Bancaire",
                          "Épargne",
                          "Mobile Money"
                        ];

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
                                  ? cardColors[index].withAlpha(100)
                                  : cardColors[index].withAlpha(50),
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
                                        ? cardColors[index].withAlpha(50)
                                        : cardColors[index].withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    index == 0 ? Icons.account_balance :
                                    index == 1 ? Icons.savings :
                                    Icons.phone_android,
                                    color: cardColors[index],
                                    size: 20,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "100.000 FCFA",
                                  style: TextStyle(
                                    color: cardColors[index],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  cardTitles[index],
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
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        Navigator.push(context, createRoute(EditeProfile()));
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

                ],
              ),
            )
          ],
        ),
      ),

    );
  }
}