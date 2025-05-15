import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/transaction_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/account_type_enum.dart';
import 'package:trackmoney/utils/date_utils.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
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
  bool hasAllAccounts = false;
  // Suppression du DateFormat car nous utiliserons notre propre fonction pour les mois en français
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
    comptesContainsAll();
  }

  void fetchTransactions() async {
    try {
      var date = DateTime.now();
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
      if (mounted) {
        SnackbarNotifier.show(
          context: context,
          message: "Erreur lors de l'obtention des transactions: $e",
          type: 'error',
        );
      }
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
    var today = DateTime.now();
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

  void comptesContainsAll(){
    // Vérifier si tous les types de comptes sont présents
    bool hasBan = false;
    bool hasMob = false;
    bool hasEsp = false;

    for (var compte in comptes){
      if (compte.type == AccountTypeEnum.espece) {
        hasEsp = true;
      }
      else if (compte.type == AccountTypeEnum.mobile) {
        hasMob = true;
      }
      else if (compte.type == AccountTypeEnum.bancaire) {
        hasBan = true;
      }
    }

    // Mettre à jour hasAllAccounts si tous les types sont présents
    hasAllAccounts = hasEsp && hasBan && hasMob;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Comptes', subtitle: '${comptes.length} ${comptes.length>1 ? 'comptes personnels':'compte personnel'} '),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : comptes.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      hasAllAccounts ? Container() :
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surfaceContainerHighest
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.black26
                                  : Colors.grey.withAlpha(30),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircularAddAccountButton(
                              onAccountLoad: (value) {
                                refreshAccounts();
                              },
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Ajouter un autre compte personnel",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height - 200,
                        margin: EdgeInsets.only(top: 8),
                        child: DefaultTabController(
                          animationDuration: tabAnimationDuration,
                          length: comptes.length,
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.black26
                                          : Colors.grey.withAlpha(20),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TabBar(
                                  labelColor: theme.colorScheme.primary,
                                  unselectedLabelColor: theme.brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  tabs: comptes
                                      .map((compte) => Tab(
                                            text: compte.type,
                                            height: 46,
                                          ))
                                      .toList(),
                                ),
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
                                                        .revenu &&
                                                transaction.accountId ==
                                                    compte.id)
                                            .length,
                                        'amount': transactions
                                            .where((transaction) =>
                                                transaction.type ==
                                                    TransactionTypesEnum
                                                        .revenu &&
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
                                            accountId: compte.id,
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
                                          Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: theme.brightness == Brightness.dark
                                                  ? theme.colorScheme.surfaceContainerHighest
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.brightness == Brightness.dark
                                                      ? Colors.black26
                                                      : Colors.grey.withAlpha(30),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary.withAlpha(30),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        Icons.bar_chart,
                                                        color: theme.colorScheme.primary,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Text(
                                                      "Transactions du mois de ${getMonthNameInFrench(DateTime.now().month)}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: theme.brightness == Brightness.dark
                                                            ? Colors.grey[200]
                                                            : Colors.grey[800],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TransactionCard(
                                                        icon: Icons.download_outlined,
                                                        title: "Entrées",
                                                        transactionCount: transactionInStats['count'],
                                                        price: transactionInStats['amount'],
                                                        priceColor: Colors.green
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Expanded(
                                                      child: TransactionCard(
                                                        icon: Icons.logout_outlined,
                                                        iconBackgroundColor: Colors.red,
                                                        title: "Sorties",
                                                        transactionCount: transactionOutStats['count'],
                                                        price: transactionOutStats['amount'],
                                                        priceColor: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          transactionsData.isNotEmpty
                                              ? _buildTransactionSummary(compte)
                                              : Container()
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
    final theme = Theme.of(context);
    return Center(
      child: Container(
        height: 500,
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black26
                  : Colors.grey.withAlpha(30),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.wallet,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Ajoutez Votre Premier Portefeuille',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Créez un compte pour commencer à suivre vos finances',
              style: TextStyle(
                fontSize: 16,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 220, // Augmenté la largeur pour éviter le débordement
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Afficher la boîte de dialogue pour ajouter un compte
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: CircularAddAccountButton(
                            onAccountLoad: (value) {
                              refreshAccounts();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: theme.colorScheme.primary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Utiliser MainAxisSize.min pour que le Row prenne la taille minimale nécessaire
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Ajouter un compte",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildTransactionSummary(AccountModel compte) {
    final theme = Theme.of(context);
    // _getTodayTransactions();
    return Column(
      children: [
        if (todayTransactions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black26
                      : Colors.grey.withAlpha(30),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.blue.withAlpha(50)
                            : Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.today,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Aujourd'hui",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[200]
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: _buildTransactionItemsList(todayTransactions, compte),
                ),
              ],
            ),
          ),
        if (transactionsData.isNotEmpty)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHighest
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black26
                      : Colors.grey.withAlpha(30),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.primary.withAlpha(50)
                            : theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Transactions du mois",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[200]
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: _buildTransactionItemsList(transactionsData, compte),
                ),
              ],
            ),
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
