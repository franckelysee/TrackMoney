import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';
import 'package:intl/intl.dart'; // Pour récupérer l'année actuelle



class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [Colors.cyanAccent, Colors.blue];
  List<Color> purpleGradientColors = [Colors.deepPurpleAccent, Colors.indigo];

  bool showAvg = false;
  List<Map<String, dynamic>> transactionsData = [];
  List<FlSpot> revenuData = [];
  List<FlSpot> depenseData = [];
  double maxtransactionValue = 0.0;

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  void getTransactions() async {
    transactionsData = await getMonthlySummary();
    setState(() {
      calculateChartData();
    });
  }

  void calculateChartData() {
    double maxRevenu = 0.0;
    double maxDepense = 0.0;
    revenuData = [];
    depenseData = [];

    for (var transaction in transactionsData) {
      double revenu = transaction["revenu"].toDouble();
      double depense = transaction["depense"].toDouble();

      revenuData.add(FlSpot(transaction["month"].toDouble(), revenu));
      depenseData.add(FlSpot(transaction["month"].toDouble(), depense));

      if (revenu > maxRevenu) maxRevenu = revenu;
      if (depense > maxDepense) maxDepense = depense;
    }

    maxtransactionValue = maxRevenu > maxDepense ? maxRevenu : maxDepense;
  }

  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final List<TransactionModel> transactions = await Database.getAllTransactions();
    int currentYear = DateTime.now().year;
    Map<int, Map<String, dynamic>> monthlyData = {};

    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = {"month": i, "revenu": 0, "depense": 0};
    }

    for (var transaction in transactions) {
      DateTime date = transaction.date;
      if (date.year == currentYear) {
        int month = date.month;
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
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: Colors.grey.withOpacity(0.5),
      elevation: 2,
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.70,
            child: Padding(
              padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
              child: RepaintBoundary(
                child: LineChart(showAvg ? avgData() : mainData()),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg ? Colors.blue.withOpacity(0.5) : Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reste du code (bottomTitleWidgets, mainData, avgData)...
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    if (value.toInt() >= 1 && value.toInt() <= 12) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(months[value.toInt() - 1], style: style),
      );
    }
    return Container();
  }
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(226, 187, 187, 187),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(226, 187, 187, 187),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(
          axisNameWidget: Text(""),
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 45)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                      width: 10, height: 10, color: Colors.deepPurpleAccent),
                  SizedBox(width: 3),
                  Text("Dépenses"),
                ],
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.cyanAccent),
                  SizedBox(width: 3),
                  Text("Revenus"),
                ],
              )
            ],
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: 12, // Affichage pour tout le mois
      minY: 0,
      maxY: maxtransactionValue, // Ajustable selon les données
      lineBarsData: [
        LineChartBarData(
          spots: revenuData,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: depenseData,
          isCurved: true,
          gradient: LinearGradient(colors: purpleGradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: purpleGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class LineChartSample extends StatefulWidget {
  const LineChartSample({super.key});

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<Color> gradientColors = [
    Colors.cyanAccent,
    Colors.blue,
  ];
  List<Color> purpleGradientColors = [
    Colors.deepPurpleAccent,
    Colors.indigo,
  ];

  bool showAvg = false;
  List<TransactionModel> transactionsPerMonth = [];
  List<TransactionModel> transactionsPerMonthDepense = [];
  List<TransactionModel> transactionsPerMonthRevenu = [];
  double maxtransactionValue = 0.0;

  List<Map<String, dynamic>> transactions = [
    {"day": 1, "revenu": 200, "depense": 100},
    {"day": 2, "revenu": 300, "depense": 200},
    {"day": 3, "revenu": 150, "depense": 180},
    {"day": 4, "revenu": 100, "depense": 250},
    {"day": 5, "revenu": 400, "depense": 300},
    {"day": 6, "revenu": 500, "depense": 350},
    {"day": 7, "revenu": 600, "depense": 400},
  ];
  List<Map<String, dynamic>> transactionsData = [];

  void getTransactions() async {
    transactionsPerMonth = await Database.getAllTransactions();
    transactionsData = await getMonthlySummary();
    setState(() {
      maxtransactionValue = getMaxTransactionValue();
    });
  }

  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final List<TransactionModel> transactions =
        await Database.getAllTransactions();

    // Obtenir l'année actuelle
    int currentYear = DateTime.now().year;

    // Initialiser un Map pour stocker les sommes
    Map<int, Map<String, dynamic>> monthlyData = {};

    // Initialiser chaque mois avec 0
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = {"month": i, "revenu": 0, "depense": 0};
    }

    // Parcourir toutes les transactions
    for (var transaction in transactions) {
      DateTime date = transaction.date; // Supposons que tu as un champ date
      if (date.year == currentYear) {
        int month = date.month;

        if (transaction.type == TransactionTypesEnum.revenu) {
          monthlyData[month]!["revenu"] += transaction.amount;
        } else if (transaction.type == TransactionTypesEnum.depense) {
          monthlyData[month]!["depense"] += transaction.amount;
        }
      }
    }

    // Transformer en liste
    return monthlyData.values.toList();
  }

  List<FlSpot> getRevenuData() {
    return transactionsData
        .map((transaction) => FlSpot(
            transaction["month"].toDouble(), transaction["revenu"].toDouble()))
        .toList();
  }

  List<FlSpot> getDepenseData() {
    return transactionsData
        .map((transaction) => FlSpot(
            transaction["month"].toDouble(), transaction["depense"].toDouble()))
        .toList();
  }

  double getMaxTransactionValue() {
    double maxRevenu = transactionsData
        .map((e) => e["revenu"].toDouble())
        .reduce((a, b) => a > b ? a : b);
    double maxDepense = transactionsData
        .map((e) => e["depense"].toDouble())
        .reduce((a, b) => a > b ? a : b);

    return (maxRevenu > maxDepense ? maxRevenu : maxDepense);
  }

  @override
  void initState() {
    // TODO: implement initState
    getTransactions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 2,
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'avg',
                  style: TextStyle(
                    fontSize: 12,
                    color: showAvg
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text(
          'Jan',
          style: style,
        );
        break;
      case 2:
        text = const Text(
          'Feb',
          style: style,
        );
        break;
      case 3:
        text = const Text(
          'Mar',
          style: style,
        );
        break;
      case 4:
        text = const Text(
          'Apr',
          style: style,
        );
        break;
      case 5:
        text = const Text(
          'May',
          style: style,
        );
        break;
      case 6:
        text = const Text(
          'Jun',
          style: style,
        );
        break;
      case 7:
        text = const Text(
          'Jul',
          style: style,
        );
        break;
      case 8:
        text = const Text(
          'Aug',
          style: style,
        );
        break;
      case 9:
        text = const Text(
          'Sep',
          style: style,
        );
        break;
      case 10:
        text = const Text(
          'Oct',
          style: style,
        );
        break;
      case 11:
        text = const Text(
          'Nov',
          style: style,
        );
        break;
      case 12:
        text = const Text(
          'Dec',
          style: style,
        );
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(226, 187, 187, 187),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(226, 187, 187, 187),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(
          axisNameWidget: Text(""),
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 45)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                      width: 10, height: 10, color: Colors.deepPurpleAccent),
                  SizedBox(width: 3),
                  Text("Dépenses"),
                ],
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.cyanAccent),
                  SizedBox(width: 3),
                  Text("Revenus"),
                ],
              )
            ],
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: 12, // Affichage pour tout le mois
      minY: 0,
      maxY: maxtransactionValue, // Ajustable selon les données
      lineBarsData: [
        LineChartBarData(
          spots: getRevenuData(),
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: getDepenseData(),
          isCurved: true,
          gradient: LinearGradient(colors: purpleGradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: purpleGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
