import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/chart.dart';
import 'package:trackmoney/templates/components/date_selector.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';

class AnalysePage extends StatefulWidget {
  const AnalysePage({super.key});

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  // Constantes pour éviter les répétitions
  static const tabAnimationDuration = Duration(milliseconds: 300);
  bool is_loading = true;
  bool is_loading_transac = true;
  List<TransactionModel> transactions = [];
  List<TransactionSchema> transactionsData = [];
  late DateTime selectedDate;

  // Méthode pour générer une liste de dépenses ou entrées
  Widget _buildTransactionList(String type) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    var data = transactionsData.where((element) => element.type == type).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(data.length, (index) {
          // Déterminer les couleurs en fonction du type de transaction
          Color iconBgColor;
          if (data[index].type == "depense") {
            iconBgColor = Color(0xFFF44336); // Rouge pour les dépenses
          } else {
            iconBgColor = Color(0xFF4CAF50); // Vert pour les revenus
          }

          // La date est maintenant formatée directement dans le composant NotificatedCard

          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: NotificatedCard(
              title: data[index].name!,
              titleSize: 16,
              subtitle: data[index].category,
              subtitleSize: 13,
              icon: data[index].icon,
              price: data[index].type == "depense"
                  ? -data[index].amount!
                  : data[index].amount!,
              iconBackgroundColor: iconBgColor,
              date: data[index].date!,
              backgroundColor: isDarkMode
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.white,
              textColor: isDarkMode ? Colors.white : null,
            ),
          );
        }),
      ),
    );
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
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        is_loading = false;
        is_loading_transac = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'obtention des transactions: $e')),
        );
      }
    }
  }

  Future<List<TransactionSchema>> getAllTransactions() async {
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
    return transactionsData;
  }

  void updateTransaction(DateTime date) async {
    setState(() {
      is_loading_transac = true;
    });

    var alltransactions = await getAllTransactions();
    // 🔹 Appliquer le filtre sur la copie des données d'origine
    List<TransactionSchema> filteredTransactions = [];
    for (var transaction in alltransactions) {
      if (transaction.date!.month == date.month &&
          transaction.date!.day == date.day &&
          transaction.date!.year == date.year) {
        filteredTransactions.add(transaction);
      }
    }

    // 🔹 Attendre un court délai pour afficher un chargement fluide
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      transactionsData = filteredTransactions;
      is_loading_transac = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Analyse / Statistiques'),
      ),
      body: is_loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Chargement des données...",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la page
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bar_chart,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statistiques financières",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Suivez vos revenus et dépenses",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Graphiques d'analyse
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black12
                              : Colors.grey.withAlpha(30),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                          child: Text(
                            "Aperçu annuel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const LineChartSample2(),
                      ],
                    ),
                  ),

                  // Sélecteur de date
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black12
                              : Colors.grey.withAlpha(20),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DateSelector(
                      onDateSelected: (value) {
                        setState(() {
                          selectedDate = value;
                          updateTransaction(selectedDate);
                        });
                      },
                    ),
                  ),

                  // Titre de la section transactions
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      "Transactions du jour",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  // Sections des onglets
                  Container(
                    height: MediaQuery.of(context).size.height - 450,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black12
                              : Colors.grey.withAlpha(30),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DefaultTabController(
                      length: 2,
                      animationDuration: tabAnimationDuration,
                      child: Column(
                        children: [
                          // Onglets Entrée/Sortie
                          Container(
                            margin: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? theme.colorScheme.surfaceContainerLow
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TabBar(
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              tabs: [
                                Tab(
                                  icon: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_downward, size: 16),
                                      SizedBox(width: 8),
                                      Text("Entrées"),
                                    ],
                                  ),
                                ),
                                Tab(
                                  icon: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_upward, size: 16),
                                      SizedBox(width: 8),
                                      Text("Sorties"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contenu des onglets
                          Expanded(
                            child: TabBarView(
                              children: [
                                is_loading_transac
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Colors.green,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              "Chargement des entrées...",
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : transactionsData.where((element) => element.type == TransactionTypesEnum.revenu).isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.account_balance_wallet_outlined,
                                                  size: 48,
                                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  "Aucune entrée pour cette date",
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : _buildTransactionList(TransactionTypesEnum.revenu),
                                is_loading_transac
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Colors.red,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              "Chargement des sorties...",
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : transactionsData.where((element) => element.type == TransactionTypesEnum.depense).isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.account_balance_wallet_outlined,
                                                  size: 48,
                                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  "Aucune sortie pour cette date",
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : _buildTransactionList(TransactionTypesEnum.depense),
                              ],
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
