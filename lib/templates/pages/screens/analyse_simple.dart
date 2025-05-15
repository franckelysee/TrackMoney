import 'package:flutter/material.dart';
import 'package:trackmoney/templates/header.dart';

class AnalyseSimplePage extends StatefulWidget {
  const AnalyseSimplePage({super.key});

  @override
  State<AnalyseSimplePage> createState() => _AnalyseSimplePageState();
}

class _AnalyseSimplePageState extends State<AnalyseSimplePage> {
  bool _isLoading = false;

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

                  // Message temporaire à la place du graphique
                  Container(
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
                          "Aperçu annuel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 80,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Graphique en cours de maintenance",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Nous travaillons à améliorer cette fonctionnalité",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statistiques simplifiées
                  Container(
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
                          "Résumé des transactions",
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
                                amount: "0",
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
                                amount: "0",
                                theme: theme,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

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
}
