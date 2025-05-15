import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  // Couleurs optimisées pour le mode clair et sombre
  final List<Color> revenueGradientColors = [
    Color(0xFF4CAF50),  // Vert plus foncé
    Color(0xFF81C784),  // Vert plus clair
  ];

  final List<Color> expenseGradientColors = [
    Color(0xFFF44336),  // Rouge plus foncé
    Color(0xFFE57373),  // Rouge plus clair
  ];

  // Couleurs semi-transparentes pour les zones sous les courbes
  final List<Color> revenueAreaColors = [
    Color(0x334CAF50),  // Vert plus foncé avec alpha
    Color(0x3381C784),  // Vert plus clair avec alpha
  ];

  final List<Color> expenseAreaColors = [
    Color(0x33F44336),  // Rouge plus foncé avec alpha
    Color(0x33E57373),  // Rouge plus clair avec alpha
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> _transactionsData = [];
  List<FlSpot> _revenueData = [];
  List<FlSpot> _expenseData = [];
  double _maxTransactionValue = 1000.0; // Valeur par défaut pour éviter 0

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Chargement optimisé des transactions
  Future<void> _loadTransactions() async {
    try {
      final data = await _getMonthlySummary();

      if (mounted) {
        setState(() {
          _transactionsData = data;
          _calculateChartData();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Utiliser un logger serait préférable en production
      debugPrint('Erreur lors du chargement des transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Calcul optimisé des données du graphique
  void _calculateChartData() {
    double maxRevenue = 0.0;
    double maxExpense = 0.0;
    _revenueData = [];
    _expenseData = [];

    for (var transaction in _transactionsData) {
      final month = transaction["month"].toDouble();
      final revenue = transaction["revenu"].toDouble();
      final expense = transaction["depense"].toDouble();

      _revenueData.add(FlSpot(month, revenue));
      _expenseData.add(FlSpot(month, expense));

      maxRevenue = revenue > maxRevenue ? revenue : maxRevenue;
      maxExpense = expense > maxExpense ? expense : maxExpense;
    }

    // Ajouter une marge de 10% pour une meilleure visualisation
    _maxTransactionValue = (maxRevenue > maxExpense ? maxRevenue : maxExpense) * 1.1;

    // Assurer une valeur minimale pour éviter les graphiques vides
    _maxTransactionValue = _maxTransactionValue < 1000 ? 1000 : _maxTransactionValue;

    // Trier les données par mois
    _revenueData.sort((a, b) => a.x.compareTo(b.x));
    _expenseData.sort((a, b) => a.x.compareTo(b.x));
  }

  // Récupération optimisée des données mensuelles
  Future<List<Map<String, dynamic>>> _getMonthlySummary() async {
    final List<TransactionModel> transactions = await Database.getAllTransactions();
    final int currentYear = DateTime.now().year;
    final Map<int, Map<String, dynamic>> monthlyData = {};

    // Initialiser les données pour chaque mois
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = {"month": i, "revenu": 0, "depense": 0};
    }

    // Traitement par lots pour améliorer les performances
    for (var transaction in transactions) {
      final DateTime date = transaction.date;
      if (date.year == currentYear) {
        final int month = date.month;

        if (transaction.type == TransactionTypesEnum.revenu) {
          monthlyData[month]!["revenu"] += transaction.amount;
        } else if (transaction.type == TransactionTypesEnum.depense) {
          monthlyData[month]!["depense"] += transaction.amount;
        }
      }
    }

    return monthlyData.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Chargement du graphique...",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Aperçu annuel ${DateTime.now().year}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          // Légende du graphique
                          Row(
                            children: [
                              _buildLegendItem(
                                "Revenus",
                                revenueGradientColors[0],
                                isDarkMode
                              ),
                              SizedBox(width: 12),
                              _buildLegendItem(
                                "Dépenses",
                                expenseGradientColors[0],
                                isDarkMode
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Graphique avec RepaintBoundary pour optimiser le rendu
                    RepaintBoundary(
                      child: AspectRatio(
                        aspectRatio: 1.70,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 24, 18, 12),
                          child: LineChart(_buildChartData(isDarkMode)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // Widget pour créer un élément de légende
  Widget _buildLegendItem(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Widget pour les étiquettes du bas (mois)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final months = ["Jan", "Fév", "Mar", "Avr", "Mai", "Jun", "Jul", "Aoû", "Sep", "Oct", "Nov", "Déc"];

    if (value.toInt() >= 1 && value.toInt() <= 12) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(months[value.toInt() - 1], style: style),
      );
    }
    return SizedBox.shrink();
  }

  // Construction optimisée des données du graphique
  LineChartData _buildChartData(bool isDarkMode) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // Utilisation des propriétés compatibles avec votre version de fl_chart
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final isRevenue = barSpot.barIndex == 0;
              return LineTooltipItem(
                '${isRevenue ? "Revenus" : "Dépenses"}: ${barSpot.y.toStringAsFixed(0)}',
                TextStyle(
                  color: isRevenue
                      ? revenueGradientColors[0]
                      : expenseGradientColors[0],
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: _maxTransactionValue / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDarkMode
                ? Colors.grey[800]!
                : Colors.grey[300]!,
            strokeWidth: 0.8,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: isDarkMode
                ? Colors.grey[800]!
                : Colors.grey[300]!,
            strokeWidth: 0.8,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0) return SizedBox.shrink();

              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}k'
                      : value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: 12,
      minY: 0,
      maxY: _maxTransactionValue,
      lineBarsData: [
        // Données des revenus
        LineChartBarData(
          spots: _revenueData,
          isCurved: true,
          curveSmoothness: 0.3,
          gradient: LinearGradient(colors: revenueGradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: revenueGradientColors[0],
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: revenueAreaColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Données des dépenses
        LineChartBarData(
          spots: _expenseData,
          isCurved: true,
          curveSmoothness: 0.3,
          gradient: LinearGradient(colors: expenseGradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: expenseGradientColors[0],
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: expenseAreaColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

// Fin du fichier
