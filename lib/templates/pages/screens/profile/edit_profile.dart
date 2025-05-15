import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/utils/app_config.dart';


class EditeProfile extends StatefulWidget {
  const EditeProfile({ Key? key }) : super(key: key);

  @override
  _EditeProfileState createState() => _EditeProfileState();
}

class _EditeProfileState extends State<EditeProfile> {
  Color btnTecxtColor = Colors.white;

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
                              hintText: "Nom d'utilisateur",
                              labelText: "Nom d'utilisateur",
                            ),
                          ),

                          // Email
                          _buildFormField(
                            icon: Icons.email,
                            color: Color(0xFF4CAF50),
                            child: CustomTextFormField(
                              hintText: "E-mail",
                              labelText: "E-mail",
                            ),
                          ),

                          // Mot de passe
                          _buildFormField(
                            icon: Icons.lock,
                            color: Color(0xFFFFA726),
                            child: CustomTextFormField(
                              hintText: "Mot de passe",
                              labelText: "Mot de passe",
                              isPassword: true,
                              suffixIcon: IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.remove_red_eye_sharp, color: Colors.grey),
                              ),
                            ),
                          ),

                          // Date de naissance
                          _buildFormField(
                            icon: Icons.cake,
                            color: Color(0xFFE57373),
                            child: CustomTextFormField(
                              hintText: "12/04/2000",
                              labelText: "Date de naissance",
                              suffixIcon: IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.calendar_month, color: Colors.grey),
                              ),
                            ),
                          ),

                          // Pays
                          _buildFormField(
                            icon: Icons.public,
                            color: Color(0xFF42A5F5),
                            child: CustomTextFormField(
                              hintText: "Pays",
                              labelText: "Pays",
                            ),
                          ),

                          // Ville
                          _buildFormField(
                            icon: Icons.location_city,
                            color: Color(0xFF9575CD),
                            child: CustomTextFormField(
                              hintText: "Ville",
                              labelText: "Ville",
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
                            initialValue: 'XAF',
                            items: ['XAF', 'EUR', 'USD', 'GBP'],
                            onChanged: (value){}
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
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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