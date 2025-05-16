// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 5;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String?,
      username: fields[1] as String?,
      email: fields[2] as String?,
      password: fields[3] as String?,
      birthDate: fields[4] as DateTime?,
      country: fields[5] as String?,
      city: fields[6] as String?,
      profileImagePath: fields[7] as String?,
      coverImagePath: fields[8] as String?,
      defaultCurrency: fields[9] as String?,
      isLoggedIn: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.birthDate)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.city)
      ..writeByte(7)
      ..write(obj.profileImagePath)
      ..writeByte(8)
      ..write(obj.coverImagePath)
      ..writeByte(9)
      ..write(obj.defaultCurrency)
      ..writeByte(10)
      ..write(obj.isLoggedIn)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
