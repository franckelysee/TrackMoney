import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/pages/screens/account_page.dart';
import 'package:trackmoney/utils/notification_type_enum.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:uuid/uuid.dart';

class SelectAccountType extends StatefulWidget {
  final Color? backgroundColor;
  final String acountType;
  final String title;
  const SelectAccountType(
      {super.key,
      required this.title,
      this.backgroundColor,
      required this.acountType});

  @override
  State<SelectAccountType> createState() => _SelectAccountTypeState();
}

class _SelectAccountTypeState extends State<SelectAccountType> {
  List<AccountModel> comptes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccount();
  }

  void getAccount() async{
    comptes = await Database.getAllAccounts();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Déterminer l'icône en fonction du type de compte
    IconData accountIcon;
    if (widget.acountType.toLowerCase() == 'bancaire') {
      accountIcon = Icons.account_balance;
    } else if (widget.acountType.toLowerCase() == 'mobile') {
      accountIcon = Icons.phone_android;
    } else if (widget.acountType.toLowerCase() == 'espece') {
      accountIcon = Icons.wallet;
    } else {
      accountIcon = Icons.credit_card;
    }

    return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.backgroundColor ?? const Color(0xFF1A2431),
              (widget.backgroundColor ?? const Color(0xFF1A2431)).withAlpha(220),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? const Color(0xFF1A2431)).withAlpha(70),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 2 - 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Icône du type de compte
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                accountIcon,
                color: Colors.white,
                size: 32,
              ),
            ),

            // Titre du type de compte
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton d'ajout
            CircularButton(
              icon: Icons.add,
              iconColor: Colors.white,
              onpressed: () {
                // Navigate to Add Account screen
                bool already = false;
                for(var compte in comptes){
                  if (compte.type!.toLowerCase() == widget.acountType.toLowerCase()) {
                    already = true;
                    break;
                  }
                }
                if (already) {

                  SnackbarNotifier.show(
                    context: context,
                    message: "Ce Compte existe déja vous ne pouvez pas avoir deux meme comptes",
                    type: 'warning',
                    durationInSeconds: 5
                  );
                  Navigator.pop(context, true);
                  var notification = NotificationModel(
                    notificationId: Uuid().v4(),
                    title: "Duplication de compte",
                    content: "Eviter de créer plusieurs comptes de meme type",
                    type: NotificationTypeEnum.RAPPEL,
                    isRead: false,
                    isArchived: false,
                    date: DateTime.now());
                  Database.addNotification(notification);

                }else{
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: AccountPage(
                        type: widget.acountType,
                      ),
                    ),
                  ).then((value) {
                    if (value == true && mounted) {
                      // Refresh the AccountPage
                      Navigator.pop(context, true);
                      setState(() {
                        // Your code to refresh the AccountPage goes here
                      });
                    }
                  });
                }
              },
              color: Color(0xFFD9D9D9),
            )
          ],
        ));
  }
}
