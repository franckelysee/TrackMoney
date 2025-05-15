import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/templates/components/chart.dart';
import 'package:trackmoney/templates/components/date_selector.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/date_utils.dart';
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
  List<TransactionSchema> _allTransactionsData = []; // Stockage de toutes les transactions
  late DateTime selectedDate;

  // Variables pour le filtre par année
  int _selectedYear = DateTime.now().year;
  List<int> _availableYears = [];
  bool _loadingYears = true;

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
      final categoryMap = <String, dynamic>{};
      for (var category in categories) {
        categoryMap[category.id] = category;
      }

      if (mounted) {
        setState(() {
          transactions = fetchedTransactions;

          // Transformation optimisée des données
          _allTransactionsData = transactions.map((transaction) {
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
          _allTransactionsData.sort((a, b) => b.date!.compareTo(a.date!));

          // Initialiser transactionsData avec toutes les transactions
          transactionsData = List.from(_allTransactionsData);

          is_loading = false;
          is_loading_transac = false;

          // Initialiser la date sélectionnée à aujourd'hui
          selectedDate = DateTime.now();

          // Filtrer les transactions pour la date actuelle
          updateTransaction(selectedDate);
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
    if (_allTransactionsData.isEmpty) {
      await fetchTransactions();
      return _allTransactionsData;
    }
    return _allTransactionsData;
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
      if (_allTransactionsData.isEmpty) {
        await fetchTransactions();
        return; // fetchTransactions appellera updateTransaction à nouveau
      }

      // Filtrage optimisé des transactions à partir de toutes les transactions
      final filteredTransactions = _allTransactionsData.where((transaction) {
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

        // Afficher un message si aucune transaction n'est trouvée
        if (filteredTransactions.isEmpty) {
          debugPrint('Aucune transaction trouvée pour la date: ${date.toString()}');
        } else {
          debugPrint('${filteredTransactions.length} transactions trouvées pour la date: ${date.toString()}');
        }
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

  // Méthode pour calculer les années disponibles dans les transactions
  Future<void> _calculateAvailableYears() async {
    setState(() {
      _loadingYears = true;
    });

    try {
      // Récupérer toutes les transactions si ce n'est pas déjà fait
      if (transactions.isEmpty) {
        await fetchTransactions();
      }

      // Extraire les années uniques
      final years = transactions
          .map((transaction) => transaction.date.year)
          .toSet()
          .toList();

      // Trier les années par ordre décroissant (plus récentes en premier)
      years.sort((a, b) => b.compareTo(a));

      // S'assurer que l'année actuelle est incluse
      final currentYear = DateTime.now().year;
      if (!years.contains(currentYear)) {
        years.add(currentYear);
        years.sort((a, b) => b.compareTo(a));
      }

      if (mounted) {
        setState(() {
          _availableYears = years;
          _selectedYear = years.isNotEmpty ? years.first : currentYear;
          _loadingYears = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du calcul des années disponibles: $e');
      if (mounted) {
        setState(() {
          _loadingYears = false;
          // Assurer qu'il y a au moins l'année actuelle
          _availableYears = [DateTime.now().year];
          _selectedYear = DateTime.now().year;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions().then((_) {
      _calculateAvailableYears();
    });
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Aperçu annuel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              // Sélecteur d'année
                              _loadingYears
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0x1A6200EE), // Couleur primaire avec alpha 10%
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<int>(
                                        value: _selectedYear,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: theme.colorScheme.primary,
                                        ),
                                        elevation: 16,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        underline: Container(height: 0),
                                        onChanged: (int? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedYear = newValue;
                                            });
                                          }
                                        },
                                        items: _availableYears.map<DropdownMenuItem<int>>((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        // Graphique avec l'année sélectionnée
                        LineChartSample2(year: _selectedYear),
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
