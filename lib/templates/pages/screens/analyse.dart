import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  List<TransactionModel> transactions = [];
  List<TransactionSchema> transactionsData = [];
  late DateTime selectedDate;

  // Méthode pour générer une liste de dépenses ou entrées
  Widget _buildTransactionList(String type) {
    var data =
        transactionsData.where((element) => element.type == type).toList();
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(data.length, (index) {
              return NotificatedCard(
                title: data[index].name!,
                titleSize: 20,
                subtitle: data[index].category,
                icon: data[index].icon,
                price: data[index].type == "depense"
                    ? -data[index].amount!
                    : data[index].amount!,
                iconBackgroundColor:
                    data[index].type == "depense" ? Colors.red : Colors.green,
                date: data[index].date!,
              );
            })));
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de l\'obtention  des transactions: $e')),
      );
    }
  }

  void updateTransaction(DateTime date) async {
    is_loading = true;
    setState(() {
      transactionsData = transactionsData.where((transaction) {
        print("day : ${date.day} -- transac day : ${transaction.date!.day}");

        if (transaction.date!.month == date.month &&
            transaction.date!.day == date.day) {
          return true;
        } else {
          return false;
        }
      }).toList();
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Analyse / Statistiques'),
      ),
      body: is_loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Graphiques d'analyse
                  const LineChartSample2(),
                  const SizedBox(height: 10),

                  // Sélecteur de date
                  DateSelector(
                    onDateSeclected: (value) {
                      setState(() {
                        selectedDate = value;
                      });
                      updateTransaction(selectedDate);
                      print("selectedDate: $selectedDate");
                    },
                  ),
                  const SizedBox(height: 10),

                  // Sections des onglets
                  SizedBox(
                    height: 300,
                    child: DefaultTabController(
                      length: 2,
                      animationDuration: tabAnimationDuration,
                      child: Column(
                        children: [
                          // Onglets Entrée/Sortie
                          const TabBar(
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            tabs: [
                              Tab(text: "Entrée"),
                              Tab(text: "Sortie"),
                            ],
                          ),

                          // Contenu des onglets
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTransactionList(
                                    TransactionTypesEnum.recette),
                                _buildTransactionList(
                                    TransactionTypesEnum.depense),
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
