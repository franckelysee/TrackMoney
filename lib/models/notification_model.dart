
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 0)
class NotificationModel extends HiveObject{
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? timestamp;
  @HiveField(3)
  final String? userId;
  @HiveField(4)
  final String? receiverId;
  @HiveField(6)
  final String? notificationId;
  @HiveField(7)
  final String content;
  @HiveField(8)
  final String? status;
  @HiveField(9)
  final String type;
  @HiveField(10)
  bool isRead;
  @HiveField(11)
  bool isArchived ;


  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.isArchived,
    this.timestamp,
    this.userId,
    this.receiverId,
    this.notificationId,
    this.status,
  });

}