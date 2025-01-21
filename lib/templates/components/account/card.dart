import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/DataBase/database.dart';
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width - 40,
          height: 200,
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color ?? const Color(0xFF1A2431),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Montant disponible",
                    style: AppConfig.lightTextStyle,
                  ),
                  const Spacer(),
                  Expanded(
                    child: Text(
                      'Portefeille ${widget.accountType}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    widget.amount.toString(),
                    style: AppConfig.bigTextStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "USD",
                    style: AppConfig.bigTextStyle,
                  )
                ],
              ),
              Spacer(),
              if(!widget.isCreating)
              TextButton(
                onPressed: () {},
                child: Text(
                  "details",
                  style: TextStyle(
                    color: Color(0xFF4A6FCC),
                    fontSize: 16,
                  ),
                ),
              )
              else
              Text(
                "${widget.accountName}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if(!widget.isCreating)
        CircularAddAccountButton(
          onAccountLoad: (value) {
            widget.onAccountLoad!(value);
          }
        )
      ],
    );
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