import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/pages/screens/account_page.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountPage(type: widget.acountType,),
                  ),
                ).then((value){
                  if (value) {
                    // Refresh the AccountPage
                    Navigator.pop(context,true);
                    setState(() {
                      // Your code to refresh the AccountPage goes here
                    });
                  }
                });
              },
              color: Color(0xFFD9D9D9),
            )
          ],
        ));
  }
}
