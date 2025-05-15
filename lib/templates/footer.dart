import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/utils/app_config.dart';


class Footer extends StatefulWidget {
  const Footer({ super.key });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int currentTabIndex = 0;
  bool listenNotification = false;
  bool isNotificationOpen = false;
  int lastCount = 0;
  @override
  void initState() {
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
      setState(() {
        listenNotification = true;
        isNotificationOpen = false;
      });
      if (index == 4) {
        isNotificationOpen = true;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
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
        color: theme.colorScheme.primary,
        buttonBackgroundColor: theme.colorScheme.primary,
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
        Icon(
          Icons.account_balance_outlined,
          color: Colors.white,
          size: 24,
        ),
        Icon(
          Icons.analytics_outlined,
          color: Colors.white,
          size: 24,
        ),
        Icon(
          Icons.add_outlined,
          color: Colors.white,
          size: 28,
        ),
        Icon(
          Icons.category_outlined,
          color: Colors.white,
          size: 24,
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 24,
            ),
            ValueListenableBuilder(
              valueListenable:
                  Hive.box<NotificationModel>('notifications').listenable(),
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
                    margin: EdgeInsets.only(top: 2, right: 2),
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
        )
      ],
    ));
  }
}