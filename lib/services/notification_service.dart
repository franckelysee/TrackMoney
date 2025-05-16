// notification_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/notification_model.dart';

class NotificationService {
  static const String _boxName = 'notifications';

  // Ouvrir la boîte de notifications
  static Future<Box<NotificationModel>> _openBox() async {
    return await Hive.openBox<NotificationModel>(_boxName);
  }

  // Ajouter une notification
  static Future<void> addNotification(NotificationModel notification) async {
    final box = await _openBox();
    await box.put(notification.notificationId, notification);
  }

  // Récupérer toutes les notifications
  static Future<List<NotificationModel>> getAllNotifications() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer une notification par son ID
  static Future<NotificationModel?> getNotificationById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  // Mettre à jour une notification
  static Future<void> updateNotification(NotificationModel notification) async {
    final box = await _openBox();
    await box.put(notification.notificationId, notification);
  }

  // Supprimer une notification
  static Future<void> deleteNotification(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Marquer une notification comme lue
  static Future<void> markNotificationAsRead(String id) async {
    final box = await _openBox();
    final notification = box.get(id);
    if (notification != null) {
      notification.isRead = true;
      await box.put(id, notification);
    }
  }

  // Marquer une notification comme archivée
  static Future<void> archiveNotification(String id) async {
    final box = await _openBox();
    final notification = box.get(id);
    if (notification != null) {
      notification.isArchived = true;
      await box.put(id, notification);
    }
  }

  // Récupérer les notifications non lues
  static Future<List<NotificationModel>> getUnreadNotifications() async {
    final box = await _openBox();
    return box.values.where((notification) => !notification.isRead).toList();
  }

  // Récupérer les notifications non archivées
  static Future<List<NotificationModel>> getNonArchivedNotifications() async {
    final box = await _openBox();
    return box.values.where((notification) => !notification.isArchived).toList();
  }

  // Récupérer les notifications par type
  static Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final box = await _openBox();
    return box.values.where((notification) => notification.type == type).toList();
  }

  // Marquer toutes les notifications comme lues
  static Future<void> markAllNotificationsAsRead() async {
    final box = await _openBox();
    for (var key in box.keys) {
      final notification = box.get(key);
      if (notification != null && !notification.isRead) {
        notification.isRead = true;
        await box.put(key, notification);
      }
    }
  }

  // Supprimer toutes les notifications
  static Future<void> deleteAllNotifications() async {
    final box = await _openBox();
    await box.clear();
  }

  // Supprimer les notifications archivées
  static Future<void> deleteArchivedNotifications() async {
    final box = await _openBox();
    final keys = box.keys.where((key) => box.get(key)?.isArchived ?? false).toList();
    for (var key in keys) {
      await box.delete(key);
    }
  }
}
