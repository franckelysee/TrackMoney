import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
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
  int count =0;
  bool isNotificationOpen = false;
  int lastCount =0;
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
    _getNotificationCount();
  }

  void _getNotificationCount() async {
    count = await Database.getNotificationCount();
    lastCount = count;
    setState(() {});
  }

  void _updateCount() async {
    count = await Database.getNotificationCount();
    if (count!= lastCount) {
      setState(() {
        lastCount = count;
      });
    }else{

    }
    setState(() {
      isNotificationOpen =!isNotificationOpen;
    });
  }
  
  @override
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
            if (index == 4) {
              isNotificationOpen = true;
            }
          });
        },
        items:  [
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: Colors.white,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:  Colors.red,
                ),
                child: count != 0 ? Text(count.toString(),style: TextStyle(fontSize: 8, color: Colors.white), textAlign: TextAlign.center,) : Container(),
              )
            ],
          )
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
