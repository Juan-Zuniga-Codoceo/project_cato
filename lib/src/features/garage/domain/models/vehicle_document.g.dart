// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleDocumentAdapter extends TypeAdapter<VehicleDocument> {
  @override
  final int typeId = 5;

  @override
  VehicleDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleDocument(
      id: fields[0] as String,
      name: fields[1] as String,
      imagePath: fields[2] as String,
      dateAdded: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleDocument obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
