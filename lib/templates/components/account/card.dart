import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/templates/components/account/select_account_type.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/pages/screens/account_page.dart';
import 'package:trackmoney/utils/account_type_enum.dart';
import 'package:trackmoney/utils/app_config.dart';

class CardComponent extends StatefulWidget {
  const CardComponent({super.key, this.color, required this.amount, required this.accountType, this.accountName, this.isCreating = false, this.onAccountLoad});
  final Color? color ;
  final double amount;
  final String accountType;
  final bool isCreating;
  final String? accountName;
  final Function(dynamic)? onAccountLoad ;
  @override
  State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Déterminer la couleur de la carte en fonction du mode et du type de compte
    Color cardColor;
    if (widget.color != null) {
      cardColor = widget.color!;
    } else {
      // Couleurs par type de compte
      Map<String, Color> accountColors = {
        'bancaire': Color(0xFF6C63FF),  // Violet
        'mobile': Color(0xFF4CAF50),    // Vert
        'espece': Color(0xFFFFA726),    // Orange
      };

      // Trouver la couleur correspondante ou utiliser une couleur par défaut
      String accountType = widget.accountType.toLowerCase();
      cardColor = accountColors.containsKey(accountType)
          ? accountColors[accountType]!
          : isDarkMode ? Color(0xFF2D3748) : Color(0xFF1A2431);
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width - 40,
          height: 200,
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withAlpha(220),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cardColor.withAlpha(70),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la carte
              Row(
                children: [
                  // Icône du type de compte
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAccountIcon(widget.accountType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Type de compte
                  Expanded(
                    child: Text(
                      'Portefeuille ${widget.accountType}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Libellé du montant
              Text(
                "Montant disponible",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(200),
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 8),

              // Montant
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.amount.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "FCFA",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Pied de la carte
              Row(
                children: [
                  if(!widget.isCreating)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Détails",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Text(
                      "${widget.accountName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Spacer(),
                  if(!widget.isCreating)
                    Text(
                      "${widget.accountName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                ]
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fonction pour obtenir l'icône correspondant au type de compte
  IconData _getAccountIcon(String accountType) {
    String type = accountType.toLowerCase();
    if (type.contains('bancaire')) {
      return Icons.account_balance;
    } else if (type.contains('mobile')) {
      return Icons.phone_android;
    } else if (type.contains('espece')) {
      return Icons.wallet;
    } else {
      return Icons.credit_card;
    }
  }
}


class CircularAddAccountButton extends StatefulWidget {
  const CircularAddAccountButton({super.key, this.onAccountLoad});
  final Function(dynamic)? onAccountLoad ;

  @override
  State<CircularAddAccountButton> createState() => _CircularAddAccountButtonState();
}

class _CircularAddAccountButtonState extends State<CircularAddAccountButton> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
          icon: Icons.add,
          onpressed: () {
            // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context){
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 40,horizontal: 20),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SelectAccountType(title: "Portefeuille Bancaire",backgroundColor: Color(0xFF1A2431),acountType: AccountTypeEnum.bancaire,),
                        SizedBox(width: 20,),
                        SelectAccountType(title: "Portefeuille Mobile",backgroundColor: Color(0xFF838486),acountType: AccountTypeEnum.mobile,),
                        SizedBox(width: 20,),
                        SelectAccountType(title: "Portefeuille Espece",backgroundColor: Color(0xFF1A2431),acountType: AccountTypeEnum.espece,),
                      ],
                    ),
                  ),
                );
              }
            ).then((value){
              try {
                widget.onAccountLoad!(value);
              } catch (e) {

              }
            });

          },
        );
  }
}