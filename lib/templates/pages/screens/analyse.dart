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

  // Méthode optimisée pour générer une liste de dépenses ou entrées
  Widget _buildTransactionList(String type) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Filtrage optimisé des données
    final data = transactionsData.where((element) => element.type == type).toList();

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
              type == TransactionTypesEnum.revenu
                  ? "Aucune entrée pour cette date"
                  : "Aucune sortie pour cette date",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Utilisation de ListView.builder au lieu de SingleChildScrollView + Column + List.generate
    // pour une meilleure performance avec de grandes listes
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
            title: item.name!,
            titleSize: 16,
            subtitle: item.category,
            subtitleSize: 13,
            icon: item.icon,
            price: item.type == "depense" ? -item.amount! : item.amount!,
            iconBackgroundColor: iconBgColor,
            date: item.date!,
            backgroundColor: isDarkMode
                ? theme.colorScheme.surfaceContainerLow
                : Colors.white,
            textColor: isDarkMode ? Colors.white : null,
          ),
        );
      },
    );
  }



  // Méthode optimisée pour récupérer les transactions initiales
  Future<void> fetchTransactions() async {
    try {
      // Utilisation de Future.wait pour exécuter les requêtes en parallèle
      final results = await Future.wait([
        Database.getAllTransactions(),
        Database.getAllCategories(),
      ]);

      final fetchedTransactions = results[0] as List<TransactionModel>;
      final categories = results[1] as List<dynamic>;

      // Création d'une Map pour un accès rapide aux catégories par ID
      final categoryMap = Map<String, dynamic>();
      for (var category in categories) {
        categoryMap[category.id] = category;
      }

      if (mounted) {
        setState(() {
          transactions = fetchedTransactions;

          // Transformation optimisée des données
          transactionsData = transactions.map((transaction) {
            final category = categoryMap[transaction.categoryId];

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

          // Tri des transactions par date (plus récentes en premier)
          transactionsData.sort((a, b) => b.date!.compareTo(a.date!));

          is_loading = false;
          is_loading_transac = false;

          // Initialiser la date sélectionnée à aujourd'hui
          selectedDate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          is_loading = false;
          is_loading_transac = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des transactions: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Méthode optimisée pour récupérer toutes les transactions
  Future<List<TransactionSchema>> getAllTransactions() async {
    if (transactions.isEmpty) {
      await fetchTransactions();
      return transactionsData;
    }
    return transactionsData;
  }

  // Méthode optimisée pour filtrer les transactions par date
  Future<void> updateTransaction(DateTime date) async {
    if (!mounted) return;

    setState(() {
      is_loading_transac = true;
      selectedDate = date;
    });

    try {
      // Vérifier si nous avons déjà les données
      if (transactions.isEmpty) {
        await fetchTransactions();
      }

      // Filtrage optimisé des transactions
      final filteredTransactions = transactionsData.where((transaction) {
        final transactionDate = transaction.date!;
        return transactionDate.year == date.year &&
               transactionDate.month == date.month &&
               transactionDate.day == date.day;
      }).toList();

      if (mounted) {
        setState(() {
          transactionsData = filteredTransactions;
          is_loading_transac = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          is_loading_transac = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du filtrage des transactions: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Widget pour afficher un indicateur de chargement
  Widget _buildLoadingIndicator(String message, Color color, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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

                          // Contenu des onglets - Optimisé pour éviter les reconstructions inutiles
                          Expanded(
                            child: TabBarView(
                              // Réduire les reconstructions inutiles
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Onglet des revenus
                                is_loading_transac
                                    ? _buildLoadingIndicator(
                                        "Chargement des entrées...",
                                        Colors.green,
                                        isDarkMode,
                                      )
                                    : _buildTransactionList(TransactionTypesEnum.revenu),

                                // Onglet des dépenses
                                is_loading_transac
                                    ? _buildLoadingIndicator(
                                        "Chargement des sorties...",
                                        Colors.red,
                                        isDarkMode,
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
