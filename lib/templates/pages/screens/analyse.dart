import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackmoney/templates/components/chart.dart';
import 'package:trackmoney/templates/components/date_selector.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';

class AnalysePage extends StatefulWidget {
  const AnalysePage({super.key});

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  // Constantes pour éviter les répétitions
  static const tabAnimationDuration = Duration(milliseconds: 300);

  // Méthode pour générer une liste de dépenses ou entrées
  Widget _buildTransactionList() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
            iconBackgroundColor: Colors.yellow,
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
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Analyse / Statistiques'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Graphiques d'analyse
            const LineChartSample2(),
            const SizedBox(height: 10),

            // Sélecteur de date
            const DateSelector(),
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
                        Tab(text: "Sortie"),
                        Tab(text: "Entrée"),
                      ],
                    ),

                    // Contenu des onglets
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTransactionList(),
                          _buildTransactionList(),
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
