// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviseAdapter extends TypeAdapter<Devise> {
  @override
  final int typeId = 6;

  @override
  Devise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Devise(
      name: fields[0] as String,
      devise: fields[1] as String,
      symbol: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Devise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.devise)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
