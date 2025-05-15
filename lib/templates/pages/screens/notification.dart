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

  // Couleurs pour le mode sombre
  final notificationTypeToIconColorDark = {
    NotificationTypeEnum.INFORMATION: Color(0xFF64B5F6), // Bleu plus clair
    NotificationTypeEnum.RAPPEL: Color(0xFFFFB74D),      // Orange plus clair
    NotificationTypeEnum.ALERTE: Color(0xFFE57373),      // Rouge plus clair
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    notifications = await Database.getAllNotifications();
    notifications.sort((a, b) => b.date!.compareTo(a.date!));
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  void markAsRead(String id) {
    Database.markNotification(id);
    setState(() {
      for (var notification in notifications) {
        if (notification.notificationId == id) {
          notification.isRead = true;
        }
      }
      // notifications[index].isRead = true;
    });
  }

  void archiveNotification(String id) {
    Database.archiveNotification(id);
    setState(() {
      for (var notification in notifications) {
        if (notification.notificationId == id) {
          notification.isArchived = true;
        }
      }
      // notifications[index].isRead = true;
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
      bool typeMatches =
          selectedType == 'Toutes' || notification.type == selectedType;
      bool unreadMatches = !showUnreadOnly || !notification.isRead;
      return typeMatches && unreadMatches && !notification.isArchived;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: const AppHeader(title: 'Notifications'),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Chargement des notifications...",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la page
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Centre de notifications",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Restez informé de vos activités",
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

                  // Section de filtrage
                  Container(
                    padding: EdgeInsets.all(16),
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
                    child: _buildFilterSection(),
                  ),

                  // Compteur de notifications
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Notifications filtrées',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${filteredNotifications.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Spacer(),
                        if (filteredNotifications.isNotEmpty)
                          Text(
                            'Glisser pour plus d\'options',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Liste des notifications
                  Expanded(
                    child: filteredNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 60,
                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune notification',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Vous n\'avez aucune notification pour le moment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? theme.colorScheme.surfaceContainerLow
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black12
                                      : Colors.grey.withAlpha(20),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ListView.separated(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredNotifications.length,
                                separatorBuilder: (context, index) => SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  var notification = filteredNotifications[index];
                                  return _buildNotificationItem(notification, index);
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Row(
          children: [
            Icon(
              Icons.filter_alt,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Filtrer par type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Sélecteur de type
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? theme.colorScheme.surfaceContainerLow
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButton<String>(
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
            underline: SizedBox(),
            value: selectedType,
            onChanged: (newValue) => setState(() => selectedType = newValue!),
            items: notificationTypes.map((value) {
              IconData iconData;
              Color iconColor;

              if (value == NotificationTypeEnum.INFORMATION) {
                iconData = Icons.info;
                iconColor = Colors.blue;
              } else if (value == NotificationTypeEnum.RAPPEL) {
                iconData = Icons.warning;
                iconColor = Colors.orange;
              } else if (value == NotificationTypeEnum.ALERTE) {
                iconData = Icons.error;
                iconColor = Colors.red;
              } else {
                iconData = Icons.notifications;
                iconColor = theme.colorScheme.primary;
              }

              return DropdownMenuItem(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      iconData,
                      color: iconColor,
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      value,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: value == selectedType ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 16),

        // Titre de la section
        Row(
          children: [
            Icon(
              Icons.visibility,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Affichage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Boutons de filtrage
        _buildToggleButtons(),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton('Toutes', false),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton('Non lues', true),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isUnread) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isSelected = showUnreadOnly == isUnread;

    return InkWell(
      onTap: () => setState(() => showUnreadOnly = isUnread),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30)
              : isDarkMode
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.grey[100],
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnread ? Icons.mark_email_unread : Icons.all_inbox,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dismissible(
      key: UniqueKey(),
      background: _buildDismissBackground(
          Color(0xFF4CAF50), Icons.archive, 'Archiver', Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(
          Color(0xFFF44336), Icons.delete, 'Supprimer', Alignment.centerRight),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          archiveNotification(notification.notificationId);
        } else {
          deleteNotification(notification.notificationId);
        }
      },
      child: NotificatedCard(
        title: notification.title,
        subtitle: notification.content,
        titleSize: 16,
        subtitleSize: 14,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : Colors.white,
        textColor: notification.isRead
            ? (isDarkMode ? Colors.grey[500] : Colors.grey[600])
            : (isDarkMode ? Colors.white : Colors.black87),
        icon: _getNotificationIcon(notification.type),
        iconBackgroundColor: notification.isRead
            ? Colors.grey
            : _getNotificationIconColor(notification.type),
        iconColor: Colors.white,
        trailing: _buildPopupMenu(notification),
        onTap: () {
          if (!notification.isRead) {
            markAsRead(notification.notificationId);
          }

          // Afficher un message plus informatif
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                notification.isRead
                    ? 'Notification déjà lue'
                    : 'Notification marquée comme lue'
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    return notificationTypeToIconData[type] ?? Icons.notifications_active;
  }

  Color _getNotificationIconColor(String type) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isDarkMode) {
      return notificationTypeToIconColorDark[type] ?? Color(0xFF81C784); // Vert clair pour le mode sombre
    } else {
      return notificationTypeToIconColor[type] ?? Colors.green;
    }
  }

  Widget _buildDismissBackground(
      Color color, IconData icon, String label, Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) Icon(icon, color: Colors.white),
          if (isLeft) const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (!isLeft) const SizedBox(width: 8),
          if (!isLeft) Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(NotificationModel notification) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PopupMenuButton<String>(
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Icon(
        Icons.more_vert,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        size: 20,
      ),
      onSelected: (action) {
        if (action == 'read') {
          markAsRead(notification.notificationId);
        }
        if (action == 'archive') {
          archiveNotification(notification.notificationId);
        }
        if (action == 'delete') {
          deleteNotification(notification.notificationId);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'read',
          child: Row(
            children: [
              Icon(
                notification.isRead ? Icons.check_circle : Icons.mark_email_read,
                color: notification.isRead ? Colors.green : theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                notification.isRead ? 'Déjà lu' : 'Marquer comme lu',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(
                Icons.archive,
                color: Colors.amber,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Archiver',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Supprimer',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
