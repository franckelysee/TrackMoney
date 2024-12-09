import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackmoney/templates/components/card.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/transaction_card.dart';
import 'package:trackmoney/templates/header.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  static const tabAnimationDuration = Duration(milliseconds: 300);
  
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Comptes', subtitle: '2 comptes personnels'),
      ),
      body: DefaultTabController(
        animationDuration: tabAnimationDuration,
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Espece",),
                Tab(
                  text: "Compte bancaire",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (int i = 0; i < 2; i++)
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CardComponent(amount: 1000, accountType: 'Compte bancaire',),
                        SizedBox(height: 20,),
                        NotificatedCard(title: 'Budget du mois de Decembre', titleSize: 13, subtitle: 'Argent espece', subtitleSize: 13, price: 2478,),
                        SizedBox(height: 5,),
                        NotificatedCard(title: "Créer un objectif d'épargne", titleSize: 16, subtitle: "Fixez un objectif d'épargne", subtitleSize: 13),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text("Cash"),
                            Row(
                              children: [
                                TransactionCard(icon: Icons.download_outlined, title: "Entrées", transactionCount: 1, price: 8025, priceColor: Colors.green),
                                Spacer(),
                                TransactionCard(icon: Icons.logout_outlined,iconBackgroundColor: Colors.red, title: "Sorties", transactionCount: 39, price: 658, priceColor: Colors.red)
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text("Aujourd'hui"),
                            NotificatedCard(title: "Loyer", titleSize: 20, subtitle: "Immobilier", icon: Icons.home, price: -658,),
                            NotificatedCard(
                              title: "Burger",
                              titleSize: 20,
                              subtitle: "Nourriture",
                              icon: FontAwesomeIcons.burger,
                              iconBackgroundColor: Colors.yellow,
                              price: -18,
                            ),
                            NotificatedCard(
                              title: "Loyer",
                              titleSize: 20,
                              subtitle: "Immobilier",
                              icon: Icons.house_outlined,
                              price: -658,
                            ),
                            
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}