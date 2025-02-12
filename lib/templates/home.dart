import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';
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
  bool listenNotification = false;
  bool isNotificationOpen = false;
  int lastCount = 0;
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
    _checkNotifications();
  }

  void _checkNotifications({int? index}) {
    var box = Hive.box<NotificationModel>('notifications');
    // setState(() {
    //   listenNotification =
    //       false; // S'il y a des notifications, afficher le point rouge
    // });

    // Écoute les changements dans la boîte Hive
    box.listenable().addListener(() {
      print("new notif");
      setState(() {
        listenNotification = true;
        isNotificationOpen = false;
      });
      print(
          "is notification open = $isNotificationOpen index = ${index.toString()}");
      if (index == 4) {
        isNotificationOpen = true;
      }
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
          _checkNotifications(index: index);
        },
        items: [
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
              ValueListenableBuilder(
                valueListenable:
                    Hive.box<NotificationModel>('notifications').listenable(),
                builder: (context, Box<NotificationModel> box, _) {
                  bool hasNewNotifications = listenNotification;
                  print(
                      '$isNotificationOpen $hasNewNotifications $listenNotification');
                  if (isNotificationOpen) {
                    hasNewNotifications = false;
                  }
                  if (!hasNewNotifications) {
                    listenNotification = false;
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: null,
                      ),
                    );
                  } else {
                    // Si on ouvre la page de notifications, masquer le point rouge
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    );
                  }
                },
              )
            ],
          )
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
