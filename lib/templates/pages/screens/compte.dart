import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/transaction_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/account_type_enum.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  static const tabAnimationDuration = Duration(milliseconds: 300);
  List<AccountModel> comptes = [];
  List<TransactionSchema> transactions_data = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAccounts();
    fetchTransactions();
  }

  void fetchAccounts() async {
    comptes = await Database.getAllAccounts();
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  void fetchTransactions() async {
    try {
      var transactions = await Database.getAllTransactions();
      var categories = await Database.getAllCategories();
      setState(() {
        var data = transactions.map((TransactionModel transaction) {
          var cat = categories.firstWhere((category) {
            return category.id == transaction.categoryId;
          });
          return TransactionSchema(
              id: transaction.id,
              name: transaction.name,
              type: transaction.type,
              amount: transaction.amount,
              icon: cat.icon,
              iconcolor: cat.colorValue,
              category: cat.name,
              date: transaction.date,
              account_id: transaction.accountId);
        }).toList();
        transactions_data = data;
        transactions_data.sort((a, b) => b.date!.compareTo(a.date!));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de l\'obtention  des transactions: $e')),
      );
    }
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
      fetchTransactions();
    });
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  Future<void> transactionCounteredByType(String type) async {
    int count = 0;
    var transactionstype = comptes.where((account) {
      return account.type == type;
    }).toList();
    setState(() {
      count = transactionstype.length;
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
                  child: Container(
                    height: 500,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.wallet,
                          size: 50,
                        ),
                        Text(
                          'Ajoutez Votre Premier Portefeille ',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: 20),
                        CircularAddAccountButton(
                          onAccountLoad: (value) {
                            refreshAccounts();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircularAddAccountButton(
                                onAccountLoad: (value) {
                                  refreshAccounts();
                                },
                              ),
                              SizedBox(width: 10),
                              Text("Ajouter autre Porteifeille"),
                            ]),
                      ),
                      SizedBox(
                        height: 700,
                        child: DefaultTabController(
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
                                                  accountName: compte.name!,
                                                  onAccountLoad: (value) {
                                                    refreshAccounts();
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                NotificatedCard(
                                                  title:
                                                      'Budget du mois de Decembre',
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
                                                            icon: Icons
                                                                .download_outlined,
                                                            title: "Entrées",
                                                            transactionCount: 1,
                                                            price: 8025,
                                                            priceColor:
                                                                Colors.green),
                                                        Spacer(),
                                                        TransactionCard(
                                                            icon: Icons
                                                                .logout_outlined,
                                                            iconBackgroundColor:
                                                                Colors.red,
                                                            title: "Sorties",
                                                            transactionCount:
                                                                39,
                                                            price: 658,
                                                            priceColor:
                                                                Colors.red)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                if (transactions_data.length >
                                                    0)
                                                  Column(
                                                    children: [
                                                      Text("Aujourd'hui"),
                                                      Column(
                                                          children: List.generate(
                                                              transactions_data
                                                                  .length,
                                                              (index) {
                                                        if (transactions_data[
                                                                    index]
                                                                .account_id !=
                                                            compte.id)
                                                          return Container();
                                                        return NotificatedCard(
                                                          titleSize: 20,
                                                          icon:
                                                              transactions_data[
                                                                      index]
                                                                  .icon,
                                                          title:
                                                              transactions_data[
                                                                      index]
                                                                  .name!,
                                                          subtitle:
                                                              transactions_data[
                                                                      index]
                                                                  .category!,
                                                          price:
                                                              transactions_data[
                                                                              index]
                                                                          .type ==
                                                                      "depense"
                                                                  ? -transactions_data[
                                                                          index]
                                                                      .amount!
                                                                  : transactions_data[
                                                                          index]
                                                                      .amount!,
                                                          iconBackgroundColor:
                                                              transactions_data[
                                                                              index]
                                                                          .type ==
                                                                      "depense"
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                        );
                                                      })),
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
                      ),
                    ],
                  ),
                ),
    );
  }
}
