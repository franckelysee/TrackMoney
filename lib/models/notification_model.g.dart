// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 0;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[7] as String,
      type: fields[9] as String,
      isRead: fields[10] as bool,
      isArchived: fields[11] as bool,
      timestamp: fields[2] as String?,
      userId: fields[3] as String?,
      receiverId: fields[4] as String?,
      notificationId: fields[6] as String?,
      status: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..writeByte(5)
      ..write(obj.notificationId)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
