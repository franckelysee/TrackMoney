import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Box<NotificationModel> notificationBox;

  @override
  void initState() {
    super.initState();
    notificationBox = Hive.box<NotificationModel>('notifications');
  }

  void addNotification(NotificationModel notification)  {
    notificationBox.add(notification);
    setState(() {});
  }

  
  List<NotificationModel> get newnotifications => notificationBox.values.toList();

  void markAsRead(int index) {
    // final notification = notificationBox.getAt(index);
    // if (notification != null){
    //   notification.isRead = true;
    //   notification.save();
    // }
    setState(() {
      notifications[index].isRead = true;
    });
  }

  // Archiver une notification
  void archiveNotification(int index) {
    setState(() {
      notifications[index].isArchived = true;
    });
  }

  // Supprimer une notification
  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }
  // Types de notifications
  List<String> notificationTypes = [
    'Toutes',
    'Alerte',
    'Rappel',
    'Information'
  ];
  String selectedType = 'Toutes';
  // Exemple de données de notifications avec type et état (lue/archivée)
  List<NotificationModel> notifications = [
    NotificationModel(
        title: 'Budget dépassé',
        content: 'Alerte: Vous avez dépassé votre budget de Nourriture.',
        type: 'Alerte',
        isRead: false,
        isArchived: false),
    NotificationModel(
        title: "Paiement d'abonnement",
        content:
            'Rappel: Le paiement de votre abonnement est d�� dans 3 jours.',
        type: 'Rappel',
        isRead: false,
        isArchived: false),
    NotificationModel(
      title: 'Solde bancaire mis à jour',
      content: 'Info: Votre solde bancaire a été mis à jour.',
      type: 'Information',
      isRead: true,
      isArchived: false,
    ),
    NotificationModel(
      title: 'Transaction suspecte détectée',
      content: 'Alerte: Transaction suspecte détectée sur votre compte.',
      type: 'Alerte',
      isRead: false,
      isArchived: false,
    ),
  ];

  bool showUnreadOnly = false;
  // Filtrer les notifications en fonction du type sélectionné
  List<NotificationModel> get filteredNotifications {
    if (showUnreadOnly){
      if (selectedType != 'Toutes'){
        return notifications
            .where((notification) =>
              notification.type == selectedType 
              && notification.isRead == false 
              &&!notification.isArchived)
            .toList();
      }else{
        return notifications
            .where((notification) =>
              notification.isRead == false 
              && !notification.isArchived)
            .toList();
      }
    }
    if (selectedType == 'Toutes') {
      return notifications
          .where((notification) => !notification.isArchived)
          .toList();
    } else {
      return notifications
          .where((notification) =>
              notification.type == selectedType && !notification.isArchived)
          .toList();
    }
  }

  // Marquer une notification comme lue
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppHeader(title: 'Notification')),
      body: Column(
        children: [
          Divider(),
          // Filtre par type de notification
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    margin: EdgeInsets.only(right: 5),
                    child: Text(
                      'Filtrer par type :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                // Bouton pour défiler les notifications
                DropdownButton<String>(
                  icon: Icon(Icons.filter_list),
                  underline: null,
                  dropdownColor: Theme.of(context).cardColor,
                  value: selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue!;
                    });
                  },
                  items: notificationTypes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                Spacer(),
                // Boutons pour les notifications lues et non lues
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            showUnreadOnly = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: showUnreadOnly? Theme.of(context).cardColor:Theme.of(context).colorScheme.primary.withAlpha(50),
                          ),
                          child: Text(
                            'Tous',
                            style: TextStyle(
                                color: showUnreadOnly
                                    ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
                                    : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13
                          ),
                        ))
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            showUnreadOnly = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: showUnreadOnly? Theme.of(context).colorScheme.primary.withAlpha(50):Theme.of(context).cardColor ,
                          ),
                          child: Text(
                            'Non lu',
                            style: TextStyle(
                                color: showUnreadOnly
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 13
                          ),
                        ))
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 16),

          //
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                var notification = filteredNotifications[index];
                return Expanded(
                  child: Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(Icons.archive, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Archiver",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Supprimer",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // Archiver la notification
                        archiveNotification(index);
                      } else if (direction == DismissDirection.endToStart) {
                        // Supprimer la notification
                        deleteNotification(index);
                      }
                    },
                    child: NotificatedCard(
                      title: notification.title.toString(),
                      subtitle: notification.content.toString(),
                      titleSize: 20,
                      textColor: notification.isRead
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary,
                      icon: Icons.notifications,
                      iconBackgroundColor: Theme.of(context).cardColor,
                      iconColor: notification.isRead
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary,
                      trailing: PopupMenuButton<String>(
                        color: Theme.of(context).cardColor,
                        onSelected: (action) {
                          if (action == 'read') {
                            markAsRead(index);
                          } else if (action == 'archive') {
                            archiveNotification(index);
                          } else if (action == 'delete') {
                            deleteNotification(index);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'read',
                              child: Text(notification.isRead
                                  ? 'Déjà lu'
                                  : 'Marquer comme lu'),
                            ),
                            PopupMenuItem<String>(
                              value: 'archive',
                              child: Text('Archiver'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Supprimer'),
                            ),
                          ];
                        },
                      ),
                      onTap: () {
                        if (!notification.isRead) {
                          markAsRead(index);
                        }
                        // Action au clic sur la notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Notification cliquée: ${notification.content}')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
