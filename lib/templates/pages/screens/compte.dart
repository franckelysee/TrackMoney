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
import 'package:trackmoney/utils/transaction_types_enum.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  static const tabAnimationDuration = Duration(milliseconds: 300);
  List<AccountModel> comptes = [];
  List<TransactionModel> transactions = [];
  List<TransactionSchema> transactionsData = [];
  Map<String, dynamic> transactionInStats = {
    'count': 0,
    'amount': 0.0,
  };
  Map<String, dynamic> transactionOutStats = {
    'count': 0,
    'amount': 0.0,
  };
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
      transactions = await Database.getAllTransactions();
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
        transactionsData = data;
        transactionsData.sort((a, b) => b.date!.compareTo(a.date!));
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
                                      .map((compte){ 
                                        setState(() {
                                          transactionInStats = {
                                            'count': transactions.where((transaction) => transaction.type == TransactionTypesEnum.recette && transaction.accountId == compte.id).length,
                                            'amount': transactions.where((transaction) => transaction.type == TransactionTypesEnum.recette && transaction.accountId == compte.id).fold(0.0, (acc, transaction) => acc + transaction.amount),
                                          };
                                          transactionOutStats = {
                                            'count': transactions.where((transaction) => transaction.type == TransactionTypesEnum.depense && transaction.accountId == compte.id).length,
                                            'amount': transactions.where((transaction) => transaction.type == TransactionTypesEnum.depense && transaction.accountId == compte.id).fold(0.0, (acc, transaction) => acc + transaction.amount),
                                          };
                                        });
                                        return SingleChildScrollView(
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
                                                            transactionCount: transactionInStats['count'],
                                                            price: transactionInStats['amount'],
                                                            priceColor:
                                                                Colors.green),
                                                        Spacer(),
                                                        TransactionCard(
                                                            icon: Icons
                                                                .logout_outlined,
                                                            iconBackgroundColor:
                                                                Colors.red,
                                                            title: "Sorties",
                                                            transactionCount:transactionOutStats['count'],
                                                            price: transactionOutStats['amount'],
                                                            priceColor:
                                                                Colors.red)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                if (transactionsData.isNotEmpty)
                                                  Column(
                                                    children: [
                                                      Text("Aujourd'hui"),
                                                      Column(
                                                        children: List.generate(transactionsData.length,(index) {
                                                          if (transactionsData[index].account_id != compte.id){
                                                            return Container();
                                                          }
                                                          return NotificatedCard(
                                                            titleSize: 20,
                                                            icon:
                                                                transactionsData[
                                                                        index]
                                                                    .icon,
                                                            title:
                                                                transactionsData[
                                                                        index]
                                                                    .name!,
                                                            subtitle:
                                                                transactionsData[
                                                                        index]
                                                                    .category!,
                                                            price:
                                                                transactionsData[
                                                                                index]
                                                                            .type ==
                                                                        "depense"
                                                                    ? -transactionsData[
                                                                            index]
                                                                        .amount!
                                                                    : transactionsData[
                                                                            index]
                                                                        .amount!,
                                                            iconBackgroundColor:
                                                                transactionsData[
                                                                                index]
                                                                            .type ==
                                                                        "depense"
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
                                                        );
                                                        }
                                                      )),
                                                    ],
                                                  )
                                              ],
                                            ),
                                          );
                                          }
                                        )
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
