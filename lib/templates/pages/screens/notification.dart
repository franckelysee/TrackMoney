import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/notification_type_enum.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];
  List<String> notificationTypes = NotificationTypeEnum().values;
  String selectedType = NotificationTypeEnum.TOUTES;
  bool showUnreadOnly = false;

  final notificationTypeToIconData = {
    NotificationTypeEnum.INFORMATION: Icons.info,
    NotificationTypeEnum.RAPPEL: Icons.warning,
    NotificationTypeEnum.ALERTE: Icons.error,
  };
  final notificationTypeToIconColor = {
    NotificationTypeEnum.INFORMATION: Colors.blue,
    NotificationTypeEnum.RAPPEL: Colors.orange,
    NotificationTypeEnum.ALERTE: Colors.red,
  };
  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    notifications = await Database.getAllNotifications();
    setState(() {});
  }

  void refreshNotifications() async {
    notifications = await Database.getAllNotifications();
    setState(() {});
  }

  void markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void archiveNotification(int index) {
    setState(() {
      notifications[index].isArchived = true;
    });
  }

  void deleteNotification(String id) {
    Database.deleteNotification(id);
    setState(() {
      notifications.removeWhere((n) => n.notificationId == id);
    });
  }

  List<NotificationModel> get filteredNotifications {
    return notifications.where((notification) {
      bool typeMatches = selectedType == 'Toutes' || notification.type == selectedType;
      bool unreadMatches = !showUnreadOnly || !notification.isRead;
      return typeMatches && unreadMatches && !notification.isArchived;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: const AppHeader(title: 'Notifications'),
      ),
      body: Column(
        children: [
          const Divider(),
          _buildFilterSection(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                var notification = filteredNotifications[index];
                return _buildNotificationItem(notification, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Text(
            'Filtrer par type :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          DropdownButton<String>(
            icon: const Icon(Icons.filter_list),
            value: selectedType,
            onChanged: (newValue) => setState(() => selectedType = newValue!),
            items: notificationTypes.map((value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
          ),
          const Spacer(),
          _buildToggleButtons(),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        _buildToggleButton('Tous', false),
        _buildToggleButton('Non lu', true),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isUnread) {
    return TextButton(
      onPressed: () => setState(() => showUnreadOnly = isUnread),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: showUnreadOnly == isUnread
              ? Theme.of(context).colorScheme.primary.withAlpha(50)
              : Theme.of(context).cardColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: showUnreadOnly == isUnread
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    return Dismissible(
      key: UniqueKey(),
      background: _buildDismissBackground(Colors.green, Icons.archive, 'Archiver', Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(Colors.red, Icons.delete, 'Supprimer', Alignment.centerRight),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          archiveNotification(index);
        } else {
          deleteNotification(notification.notificationId);
        }
      },
      child: NotificatedCard(
        title: notification.title ?? '',
        subtitle: notification.content ?? '',
        titleSize: 20,
        textColor: notification.isRead ? Colors.grey : Theme.of(context).colorScheme.secondary,
        icon: _getNotificationIcon(notification.type),
        iconBackgroundColor: Theme.of(context).cardColor,
        iconColor: notification.isRead ? Colors.grey : _getNotificationIconColor(notification.type),
        trailing: _buildPopupMenu(notification, index),
        onTap: () {
          if (!notification.isRead) markAsRead(index);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification cliquée: ${notification.content}')),
          );
        },
      ),
    );
  }

  
  IconData _getNotificationIcon(String type) {
    return notificationTypeToIconData[type] ?? Icons.notifications_active;
  }
  Color _getNotificationIconColor(String type) {
    return notificationTypeToIconColor[type] ?? Colors.green;
  }

  Widget _buildDismissBackground(Color color, IconData icon, String label, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(NotificationModel notification, int index) {
    return PopupMenuButton<String>(
      color: Theme.of(context).cardColor,
      onSelected: (action) {
        if (action == 'read') markAsRead(index);
        if (action == 'archive') archiveNotification(index);
        if (action == 'delete') deleteNotification(notification.notificationId);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'read', child: Text(notification.isRead ? 'Déjà lu' : 'Marquer comme lu')),
        const PopupMenuItem(value: 'archive', child: Text('Archiver')),
        const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
      ],
    );
  }
}
