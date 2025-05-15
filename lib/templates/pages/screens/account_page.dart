import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/utils/notification_type_enum.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:uuid/uuid.dart';

class AccountPage extends StatefulWidget {
  final String type;
  const AccountPage({super.key, required this.type});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool activeIndicator = false;
  double amount = 0;
  String name = '';
  final String id = Uuid().v4();
  @override
  void initState() {
    super.initState();
    priceController.addListener(() {
      setState(() {
        amount = double.tryParse(priceController.text) ?? 0;
      });
    });
    nameController.addListener(() {
      setState(() {
        name = nameController.text;
      });
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _addAccount() async {
    if (!_formKey.currentState!.validate()) {
      SnackbarNotifier.show(
          context: context,
          message: "Erreur de validation...",
          type: 'error',
          actionLabel: 'cancel');
      return;
    }

    setState(() {
      activeIndicator = true;
    });

    final newAccount = AccountModel(
      id: id,
      name: name,
      type: widget.type,
      balance: amount,
    );

    try {
      await Database.addAccount(newAccount);
      // notification
      var notification = NotificationModel(
          notificationId: Uuid().v4(),
          title: "Portefeuille ajouté",
          content: "Un nouveau portefeuille a été ajouté",
          type: NotificationTypeEnum.INFORMATION,
          isRead: false,
          isArchived: false,
          date: DateTime.now());

      // add notification to database
      await Database.addNotification(notification);

      SnackbarNotifier.show(
          context: context,
          message: "Compte ajouté avec success",
          type: 'success',
          actionLabel: 'cancel');
      Navigator.pop(context, true); // Retour à la page précédente
    } catch (e) {
      SnackbarNotifier.show(
          context: context,
          message: "Erreur lors de l\'ajout : $e",
          type: 'error',
          actionLabel: 'cancel');
    } finally {
      setState(() {
        activeIndicator = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Déterminer la couleur en fonction du type de compte
    Color accountColor;
    IconData accountIcon;

    switch (widget.type.toLowerCase()) {
      case 'bancaire':
        accountColor = Color(0xFF6C63FF);
        accountIcon = Icons.account_balance;
        break;
      case 'mobile':
        accountColor = Color(0xFF4CAF50);
        accountIcon = Icons.phone_android;
        break;
      case 'espece':
        accountColor = Color(0xFFFFA726);
        accountIcon = Icons.wallet;
        break;
      default:
        accountColor = theme.colorScheme.primary;
        accountIcon = Icons.credit_card;
    }

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surface
            : Color(0xFFF8F9FA),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ajouter un Portefeuille",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: activeIndicator
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: accountColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Création du portefeuille...",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec icône
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accountColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              accountIcon,
                              color: accountColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Portefeuille ${widget.type}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Configurez les détails de votre compte",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Aperçu de la carte
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: CardComponent(
                        accountType: widget.type,
                        amount: amount,
                        accountName: name.isEmpty ? "Mon portefeuille" : name,
                        isCreating: true,
                      ),
                    ),

                    // Formulaire
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black12
                                : Colors.grey.withAlpha(30),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Informations du portefeuille",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            CustomTextFormField(
                              controller: nameController,
                              labelText: "Nom du portefeuille",
                              hintText: "Ex: Mon compte bancaire",
                              prefixIcon: Icons.account_balance_wallet,
                              validator: (value) => value!.isEmpty
                                  ? "Veuillez renseigner ce champ"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              controller: priceController,
                              labelText: "Montant disponible",
                              hintText: "0.00",
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est obligatoire';
                                }
                                if (!RegExp(r'^[0-9]*\.?[0-9]+$')
                                    .hasMatch(value)) {
                                  return 'Veuillez saisir un montant valide';
                                }
                                if (double.tryParse(value)! <= 0) {
                                  return 'Veuillez saisir un montant positif';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accountColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _addAccount,
                                child: Text(
                                  'Créer le portefeuille',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
