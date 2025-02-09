import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/transaction_card.dart';
import 'package:trackmoney/templates/header.dart';
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
  List<TransactionSchema> todayTransactions = [];
  Map<String, dynamic> transactionInStats = {
    'count': 0,
    'amount': 0.0,
  };
  Map<String, dynamic> transactionOutStats = {
    'count': 0,
    'amount': 0.0,
  };
  bool isLoading = true;
  DateFormat dateFormat = new DateFormat("MMMM");
  @override
  void initState() {
    super.initState();
    fetchAccounts();
    fetchTransactions();
    _getTodayTransactions();
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
      var date = new DateTime.now();
      transactions = await Database.getAllTransactions();
      var categories = await Database.getAllCategories();
      List<TransactionSchema> data = [];
      setState(() {
        for (var transaction in transactions) {
          if (transaction.date.month == date.month &&
              transaction.date.year == date.year) {
            var cat = categories.firstWhere((category) {
              return category.id == transaction.categoryId;
            });
            data.add(TransactionSchema(
                id: transaction.id,
                name: transaction.name,
                type: transaction.type,
                amount: transaction.amount,
                icon: cat.icon,
                iconcolor: cat.colorValue,
                category: cat.name,
                date: transaction.date,
                account_id: transaction.accountId));
          }
        }

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

  Future<void> _getTodayTransactions() async {
    var today = new DateTime.now();
    var dataTransactions = await Database.getAllTransactions();
    var dataCategories = await Database.getAllCategories();
    List<TransactionSchema> newTransactions = [];
    setState(() {
      for (var transaction in dataTransactions) {
        if (transaction.date.day == today.day &&
            transaction.date.month == today.month &&
            transaction.date.year == today.year) {
          var cat = dataCategories.firstWhere((category) {
            return category.id == transaction.categoryId;
          });
          newTransactions.add(TransactionSchema(
              id: transaction.id,
              name: transaction.name,
              type: transaction.type,
              amount: transaction.amount,
              icon: cat.icon,
              iconcolor: cat.colorValue,
              category: cat.name,
              date: transaction.date,
              account_id: transaction.accountId));
        }
      }
    });
    todayTransactions = newTransactions;
    todayTransactions.sort((a, b) => b.date!.compareTo(a.date!));
    return;
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
              ? _buildEmptyState()
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
                        height: 750,
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
                                  children: comptes.map((compte) {
                                    setState(() {
                                      transactionInStats = {
                                        'count': transactions
                                            .where((transaction) =>
                                                transaction.type ==
                                                    TransactionTypesEnum
                                                        .recette &&
                                                transaction.accountId ==
                                                    compte.id)
                                            .length,
                                        'amount': transactions
                                            .where((transaction) =>
                                                transaction.type ==
                                                    TransactionTypesEnum
                                                        .recette &&
                                                transaction.accountId ==
                                                    compte.id)
                                            .fold(
                                                0.0,
                                                (acc, transaction) =>
                                                    acc + transaction.amount),
                                      };
                                      transactionOutStats = {
                                        'count': transactions
                                            .where((transaction) =>
                                                transaction.type ==
                                                    TransactionTypesEnum
                                                        .depense &&
                                                transaction.accountId ==
                                                    compte.id)
                                            .length,
                                        'amount': transactions
                                            .where((transaction) =>
                                                transaction.type ==
                                                    TransactionTypesEnum
                                                        .depense &&
                                                transaction.accountId ==
                                                    compte.id)
                                            .fold(
                                                0.0,
                                                (acc, transaction) =>
                                                    acc + transaction.amount),
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
                                              Text(
                                                "Transactions du mois de ${dateFormat.format(DateTime.now())}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20),
                                              ),
                                              Row(
                                                children: [
                                                  TransactionCard(
                                                      icon: Icons
                                                          .download_outlined,
                                                      title: "Entrées",
                                                      transactionCount:
                                                          transactionInStats[
                                                              'count'],
                                                      price: transactionInStats[
                                                          'amount'],
                                                      priceColor: Colors.green),
                                                  Spacer(),
                                                  TransactionCard(
                                                      icon:
                                                          Icons.logout_outlined,
                                                      iconBackgroundColor:
                                                          Colors.red,
                                                      title: "Sorties",
                                                      transactionCount:
                                                          transactionOutStats[
                                                              'count'],
                                                      price:
                                                          transactionOutStats[
                                                              'amount'],
                                                      priceColor: Colors.red)
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          if (transactionsData.length > 0)
                                            _buildTransactionSummary(compte)
                                        ],
                                      ),
                                    );
                                  }).toList(),
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

  Widget _buildEmptyState() {
    return Center(
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
              textAlign: TextAlign.center,
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
    );
  }

  Widget _buildTransactionSummary(AccountModel compte) {
    // _getTodayTransactions();
    return Column(
      children: [
        if (todayTransactions.length > 0)
          Column(
            children: [
              Text("Aujourd'hui",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Column(
                children: _buildTransactionItemsList(todayTransactions, compte),
              ),
            ],
          ),
        if (transactionsData.length > 0)
          Column(
            children: [
              Text(
                "Transactions du mois",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Column(
                children: _buildTransactionItemsList(transactionsData, compte),
              ),
            ],
          )
      ],
    );
  }
}

List<Widget> _buildTransactionItemsList(
    List<TransactionSchema> transactions, AccountModel compte) {
  return List.generate(transactions.length, (index) {
    if (transactions[index].account_id != compte.id) {
      return Container();
    }
    return NotificatedCard(
      titleSize: 20,
      icon: transactions[index].icon,
      title: transactions[index].name!,
      subtitle: transactions[index].category!,
      price: transactions[index].type == "depense"
          ? -transactions[index].amount!
          : transactions[index].amount!,
      iconBackgroundColor:
          transactions[index].type == "depense" ? Colors.red : Colors.green,
    );
  });
}
