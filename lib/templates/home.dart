import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/pages/screens/ajouter.dart';
import 'package:trackmoney/templates/pages/screens/analyse_improved.dart';
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
  late AnalyseImprovedPage analysePage;
  late AjouterPage ajouterPage;
  late CategoryPage categoriePage;
  late NotificationPage notificationPage;
  bool listenNotification = false;
  bool isNotificationOpen = false;
  int lastCount = 0;
  @override
  void initState() {
    comptePage = ComptePage();
    analysePage = AnalyseImprovedPage();
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, isDarkMode ? 0.3 : 0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          height: 60,
          backgroundColor: isDarkMode
              ? theme.colorScheme.surface
              : Color(0xFFF8F9FA),
          color: primaryColor,
          buttonBackgroundColor: primaryColor,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
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
            _buildNavItem(Icons.account_balance_outlined, 0),
            _buildNavItem(Icons.analytics_outlined, 1),
            _buildNavItem(Icons.add_outlined, 2),
            _buildNavItem(Icons.category_outlined, 3),
            _buildNotificationItem(4),
          ],
        ),
      ),
      body: pages[currentTabIndex],
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = currentTabIndex == index;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Icon(
        icon,
        color: Colors.white,
        size: isSelected ? 24 : 22,
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final isSelected = currentTabIndex == index;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.notifications_active_outlined,
            color: Colors.white,
            size: isSelected ? 24 : 22,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: Hive.box<NotificationModel>('notifications').listenable(),
          builder: (context, Box<NotificationModel> box, _) {
            bool hasNewNotifications = listenNotification;

            if (isNotificationOpen) {
              hasNewNotifications = false;
            }

            if (!hasNewNotifications) {
              listenNotification = false;
              return SizedBox.shrink();
            } else {
              // Si on ouvre la page de notifications, masquer le point rouge
              return Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.only(right: 2, top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              );
            }
          },
        )
      ],
    );
  }
}
