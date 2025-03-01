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
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFF1A2431),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 2 - 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            CircularButton(
              icon: Icons.add,
              iconColor: Color(0xFF22C22D),
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
                    if (value == true) {
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
