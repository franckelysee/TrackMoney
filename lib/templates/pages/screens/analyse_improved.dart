import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/chart.dart';
import 'package:trackmoney/templates/components/date_selector.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/date_utils.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';

class AnalyseImprovedPage extends StatefulWidget {
  const AnalyseImprovedPage({super.key});

  @override
  State<AnalyseImprovedPage> createState() => _AnalyseImprovedPageState();
}

class _AnalyseImprovedPageState extends State<AnalyseImprovedPage> {
  // Constante pour l'animation des onglets
  static const tabAnimationDuration = Duration(milliseconds: 300);

  bool _isLoading = true;
  List<TransactionSchema> _transactionsData = [];
  List<TransactionSchema> _allTransactionsData = [];
  DateTime selectedDate = DateTime.now();
  int selectedYear = DateTime.now().year;
  List<int> availableYears = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Méthode optimisée pour générer une liste de dépenses ou entrées
  Widget _buildTransactionList(String type) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Filtrage optimisé des données
    final data = _transactionsData.where((element) => element.type == type).toList();

    if (data.isEmpty) {
      return Center(
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
              type == 'revenu'
                  ? "Aucune entrée pour le ${selectedDate.day} ${getMonthNameInFrench(selectedDate.month)} ${selectedDate.year}"
                  : "Aucune sortie pour le ${selectedDate.day} ${getMonthNameInFrench(selectedDate.month)} ${selectedDate.year}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Utilisation de ListView.builder pour une meilleure performance avec de grandes listes
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.length,
      // Utilisation de const pour les widgets immuables
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = data[index];

        // Déterminer les couleurs en fonction du type de transaction
        final Color iconBgColor = item.type == "depense"
            ? Color(0xFFF44336) // Rouge pour les dépenses
            : Color(0xFF4CAF50); // Vert pour les revenus

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NotificatedCard(
            title: item.name ?? "Transaction",
            titleSize: 16,
            subtitle: item.category ?? "Catégorie inconnue",
            subtitleSize: 13,
            icon: item.icon ?? Icons.attach_money,
            price: item.type == "depense" ? -(item.amount ?? 0) : (item.amount ?? 0),
            iconBackgroundColor: iconBgColor,
            date: item.date ?? DateTime.now(),
            backgroundColor: isDarkMode
                ? theme.colorScheme.surfaceContainerLow
                : Colors.white,
            textColor: isDarkMode ? Colors.white : null,
          ),
        );
      },
    );
  }

  // Méthode pour charger les transactions
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer toutes les transactions
      final transactions = await Database.getAllTransactions();
      final categories = await Database.getAllCategories();

      // Transformer les transactions en TransactionSchema
      final transactionSchemas = transactions.map((transaction) {
        // Trouver la catégorie correspondante
        dynamic category;
        for (var cat in categories) {
          if (cat.id == transaction.categoryId) {
            category = cat;
            break;
          }
        }

        return TransactionSchema(
          id: transaction.id,
          name: transaction.name,
          type: transaction.type,
          amount: transaction.amount,
          icon: category?.icon,
          iconcolor: category?.colorValue,
          category: category?.name ?? 'Catégorie inconnue',
          date: transaction.date,
          account_id: transaction.accountId,
        );
      }).toList();

      // Calculer les années disponibles
      _calculateAvailableYears(transactions);

      if (mounted) {
        setState(() {
          _allTransactionsData = transactionSchemas;
          // Filtrer les transactions pour la date sélectionnée
          updateTransactions(selectedDate);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode pour mettre à jour les transactions en fonction de la date sélectionnée
  void updateTransactions(DateTime date) {
    setState(() {
      selectedDate = date;

      // Filtrage optimisé des transactions à partir de toutes les transactions
      final filteredTransactions = _allTransactionsData.where((transaction) {
        if (transaction.date == null) return false;
        final transactionDate = transaction.date!;
        return transactionDate.year == date.year &&
               transactionDate.month == date.month &&
               transactionDate.day == date.day;
      }).toList();

      _transactionsData = filteredTransactions;
    });
  }

  // Méthode pour calculer les années disponibles
  void _calculateAvailableYears(List<TransactionModel> transactions) {
    if (transactions.isNotEmpty) {
      // Extraire les années uniques
      final years = transactions
          .map((transaction) => transaction.date.year)
          .toSet()
          .toList();

      // Trier les années
      years.sort();

      setState(() {
        availableYears = years;
        // Si l'année sélectionnée n'est pas dans la liste, sélectionner la plus récente
        if (!years.contains(selectedYear) && years.isNotEmpty) {
          selectedYear = years.last;
        }
      });
    } else {
      setState(() {
        availableYears = [DateTime.now().year];
        selectedYear = DateTime.now().year;
      });
    }
  }

  // Méthode pour afficher le modal avec le graphique
  void _showChartModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? theme.colorScheme.surface
                    : Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du modal
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black12
                              : Colors.grey.withAlpha(30),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Graphique annuel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Sélecteur d'année pour le graphique
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Année",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        DropdownButton<int>(
                          value: selectedYear,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.primary,
                          ),
                          elevation: 16,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          underline: Container(
                            height: 0,
                          ),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedYear = newValue;
                              });
                            }
                          },
                          items: availableYears.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Contenu du graphique
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: FutureBuilder<List<TransactionModel>>(
                        future: Database.getAllTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Erreur lors du chargement des données",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    color: Color(0x80007BFF),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Aucune donnée disponible pour l'année $selectedYear",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            try {
                              // Essayer de charger le graphique
                              return LineChartSample2(
                                transactions: snapshot.data!,
                                selectedYear: selectedYear,
                              );
                            } catch (e) {
                              // En cas d'erreur, afficher un message
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.orange,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Impossible d'afficher le graphique",
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Erreur: $e",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Méthode pour construire les statistiques
  Widget _buildStatistics() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Calculer les statistiques pour le mois en cours
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    double totalRevenue = 0;
    double totalExpense = 0;

    for (var transaction in _allTransactionsData) {
      if (transaction.date != null &&
          transaction.date!.month == currentMonth &&
          transaction.date!.year == currentYear) {
        if (transaction.type == TransactionTypesEnum.revenu.toString()) {
          totalRevenue += transaction.amount ?? 0;
        } else if (transaction.type == TransactionTypesEnum.depense.toString()) {
          totalExpense += transaction.amount ?? 0;
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
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
          Text(
            "Résumé du mois de ${getMonthNameInFrench(currentMonth)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                  title: "Entrées",
                  amount: totalRevenue.toStringAsFixed(0),
                  theme: theme,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                  title: "Sorties",
                  amount: totalExpense.toStringAsFixed(0),
                  theme: theme,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildBalanceCard(
            totalRevenue - totalExpense,
            theme,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  // Méthode pour construire une carte de statistique
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor == Colors.green
                      ? Color(0x1A4CAF50) // Vert avec alpha 10%
                      : Color(0x1AF44336), // Rouge avec alpha 10%
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "$amount FCFA",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire la carte de solde
  Widget _buildBalanceCard(double balance, ThemeData theme, bool isDarkMode) {
    final isPositive = balance >= 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? Color(0x4C4CAF50) : Color(0x4CF44336), // Alpha 30%
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive
                  ? Color(0x1A4CAF50) // Vert avec alpha 10%
                  : Color(0x1AF44336), // Rouge avec alpha 10%
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Solde du mois",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${balance.toStringAsFixed(0)} FCFA",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire le sélecteur d'année
  Widget _buildYearSelector() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Année",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          DropdownButton<int>(
            value: selectedYear,
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
            elevation: 16,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            underline: Container(
              height: 0,
            ),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedYear = newValue;
                });
              }
            },
            items: availableYears.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
      body: _isLoading
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

                  // Sélecteur d'année
                  _buildYearSelector(),

                  // Bouton pour afficher le graphique
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showChartModal(context),
                      icon: Icon(Icons.bar_chart),
                      label: Text("Afficher le graphique"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  // Statistiques du mois
                  _buildStatistics(),

                  // Sélecteur de date
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: DateSelector(
                      onDateSelected: updateTransactions,
                    ),
                  ),

                  // Titre de la section transactions avec la date sélectionnée
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      "Transactions du ${selectedDate.day} ${getMonthNameInFrench(selectedDate.month)} ${selectedDate.year}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  // Sections des onglets avec TabController
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
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Onglet des revenus
                                _buildTransactionList('revenu'),

                                // Onglet des dépenses
                                _buildTransactionList('depense'),
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
