// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceAdapter extends TypeAdapter<Maintenance> {
  @override
  final int typeId = 1;

  @override
  Maintenance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Maintenance(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      type: fields[2] as String,
      date: fields[3] as DateTime,
      mileage: fields[4] as double,
      cost: fields[5] as double,
      notes: fields[6] as String,
      paymentMethod: fields[7] == null ? 'Efectivo' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Maintenance obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.mileage)
      ..writeByte(5)
      ..write(obj.cost)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
