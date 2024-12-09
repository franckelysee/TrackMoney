import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:trackmoney/templates/pages/screens/ajouter.dart';
import 'package:trackmoney/templates/pages/screens/analyse.dart';
import 'package:trackmoney/templates/pages/screens/categorie.dart';
import 'package:trackmoney/templates/pages/screens/compte.dart';
import 'package:trackmoney/templates/pages/screens/notification.dart';
import 'package:trackmoney/utils/app_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late ComptePage comptePage;
  late AnalysePage analysePage;
  late AjouterPage ajouterPage;
  late CategoryPage categoriePage;
  late NotificationPage notificationPage;
  @override
  void initState() {
    comptePage = ComptePage();
    analysePage = AnalysePage();
    ajouterPage = AjouterPage();
    categoriePage = CategoryPage();
    notificationPage = NotificationPage();
    pages = [
      comptePage,
      analysePage,
      ajouterPage,
      categoriePage,
      notificationPage
    ];
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: AppConfig.primaryColor,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(
            Icons.account_balance_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.analytics_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.add_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.category_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications_active_outlined,
            color: Colors.white,
          )
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
