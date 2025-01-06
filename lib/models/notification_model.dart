
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 0)
class NotificationModel extends HiveObject{
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String? timestamp;
  @HiveField(2)
  final String? userId;
  @HiveField(3)
  final String? receiverId;
  @HiveField(4)
  final String? icon;
  @HiveField(5)
  final String? notificationId;
  @HiveField(6)
  final String content;
  @HiveField(7)
  final String? status;
  @HiveField(8)
  final String type;
  @HiveField(9)
  bool isRead;
  @HiveField(10)
  bool isArchived ;


  NotificationModel({
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.isArchived,
    this.timestamp,
    this.userId,
    this.receiverId,
    this.icon,
    this.notificationId,
    this.status,
  });
}