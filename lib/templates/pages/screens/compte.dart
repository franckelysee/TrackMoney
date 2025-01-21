import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/templates/components/account/card.dart';
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
  List<AccountModel> comptes = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  void fetchAccounts() async {
    comptes = await Database.getAllAccounts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshAccounts() async {
    final updateAccounts = await Database.getAllAccounts();
    if (updateAccounts.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      comptes = updateAccounts;
    });
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Comptes', subtitle: '2 comptes personnels'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : comptes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.wallet,
                        size: 50,
                      ),
                      Text('Aucun compte'),
                      SizedBox(height: 20),
                      CircularAddAccountButton(
                        onAccountLoad: (value){
                          refreshAccounts();
                        },
                      ),
                      Text('Ajouter un Compte'),
                    ],
                  ),
                )
              : DefaultTabController(
                  animationDuration: tabAnimationDuration,
                  length: comptes.length,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: comptes
                            .map((compte) => Tab(
                                  text: compte.type,
                                ))
                            .toList(),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: comptes
                              .map((compte) => SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        CardComponent(
                                          amount: compte.balance!,
                                          accountType: compte.type!,
                                          onAccountLoad: (value){
                                            refreshAccounts();
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        NotificatedCard(
                                          title: 'Budget du mois de Decembre',
                                          titleSize: 13,
                                          subtitle: 'Argent espece',
                                          subtitleSize: 13,
                                          price: 2478,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        NotificatedCard(
                                            title:
                                                "Créer un objectif d'épargne",
                                            titleSize: 16,
                                            subtitle:
                                                "Fixez un objectif d'épargne",
                                            subtitleSize: 13),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Column(
                                          children: [
                                            Text("Cash"),
                                            Row(
                                              children: [
                                                TransactionCard(
                                                    icon:
                                                        Icons.download_outlined,
                                                    title: "Entrées",
                                                    transactionCount: 1,
                                                    price: 8025,
                                                    priceColor: Colors.green),
                                                Spacer(),
                                                TransactionCard(
                                                    icon: Icons.logout_outlined,
                                                    iconBackgroundColor:
                                                        Colors.red,
                                                    title: "Sorties",
                                                    transactionCount: 39,
                                                    price: 658,
                                                    priceColor: Colors.red)
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Column(
                                          children: [
                                            Text("Aujourd'hui"),
                                            NotificatedCard(
                                              title: "Loyer",
                                              titleSize: 20,
                                              subtitle: "Immobilier",
                                              icon: Icons.home,
                                              price: -658,
                                            ),
                                            NotificatedCard(
                                              title: "Burger",
                                              titleSize: 20,
                                              subtitle: "Nourriture",
                                              icon: FontAwesomeIcons.burger,
                                              iconBackgroundColor:
                                                  Colors.yellow,
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
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
