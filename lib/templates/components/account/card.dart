import 'package:flutter/material.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/templates/components/account/select_account_type.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/pages/screens/account_details_page.dart';
import 'package:trackmoney/utils/account_type_enum.dart';
import 'package:trackmoney/utils/currency_utils.dart';

class CardComponent extends StatefulWidget {
  const CardComponent({
    super.key,
    this.color,
    required this.amount,
    required this.accountType,
    this.accountName,
    this.isCreating = false,
    this.onAccountLoad,
    this.accountId,
    this.hideDetails = false,
  });

  final Color? color;
  final double amount;
  final String accountType;
  final bool isCreating;
  final bool hideDetails;
  final String? accountName;
  final String? accountId;
  final Function(dynamic)? onAccountLoad;
  @override
  State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> {
  String _currency = 'FCFA';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final currency = await CurrencyUtils.getUserCurrency();

      if (mounted) {
        setState(() {
          _currency = currency;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              height: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      // Type de compte
                      Expanded(
                        child: Text(
                          'Portefeuille ${widget.accountType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Libellé du montant
                  Text(
                    "Montant disponible",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(200),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Montant
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.amount.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: _isLoading
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currency,
                              style: TextStyle(
                                fontSize: 12,
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
                      if(!widget.isCreating && !widget.hideDetails)
                        GestureDetector(
                          onTap: () {
                            _navigateToAccountDetails(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Détails",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          "${widget.accountName}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Spacer(),
                      if(!widget.isCreating)
                        Text(
                          "${widget.accountName}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
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

  // Fonction pour naviguer vers la page de détails du compte
  void _navigateToAccountDetails(BuildContext context) {
    // Créer un compte temporaire avec les informations disponibles
    final tempAccount = AccountModel(
      id: widget.accountId ?? 'temp_id',
      name: widget.accountName ?? 'Mon compte',
      type: widget.accountType,
      balance: widget.amount,
    );

    // Ouvrir directement la page de détails avec le compte temporaire
    _openAccountDetailsPage(context, tempAccount);
  }

  // Fonction pour ouvrir la page de détails du compte
  void _openAccountDetailsPage(BuildContext context, AccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailsPage(account: account),
      ),
    ).then((value) {
      // Rafraîchir les données si nécessaire après le retour de la page de détails
      if (value == true && widget.onAccountLoad != null) {
        widget.onAccountLoad!(true);
      }
    });
  }
}


class CircularAddAccountButton extends StatefulWidget {
  const CircularAddAccountButton({super.key, this.onAccountLoad});
  final Function(dynamic)? onAccountLoad;

  @override
  State<CircularAddAccountButton> createState() => _CircularAddAccountButtonState();
}

class _CircularAddAccountButtonState extends State<CircularAddAccountButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CircularButton(
      icon: Icons.add,
      iconColor: Colors.white,
      color: theme.colorScheme.primary,
      onpressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: isDarkMode
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  // Barre d'indication en haut
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Titre
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(isDarkMode ? 50 : 30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Sélectionner le type de compte",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Liste des types de compte
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SelectAccountType(
                            title: "Portefeuille Bancaire",
                            backgroundColor: Color(0xFF6C63FF),
                            acountType: AccountTypeEnum.bancaire,
                          ),
                          SizedBox(width: 20),
                          SelectAccountType(
                            title: "Portefeuille Mobile",
                            backgroundColor: Color(0xFF4CAF50),
                            acountType: AccountTypeEnum.mobile,
                          ),
                          SizedBox(width: 20),
                          SelectAccountType(
                            title: "Portefeuille Espece",
                            backgroundColor: Color(0xFFFFA726),
                            acountType: AccountTypeEnum.espece,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ).then((value) {
          if (value != null && widget.onAccountLoad != null) {
            widget.onAccountLoad!(value);
          }
        });
      },
    );
  }
}