// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthRecordModelAdapter extends TypeAdapter<HealthRecordModel> {
  @override
  final int typeId = 23;

  @override
  HealthRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthRecordModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      description: fields[2] as String,
      cost: fields[3] as double,
      type: fields[4] as String,
      transactionId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecordModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.cost)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 22;

  @override
  PetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDate: fields[2] as DateTime,
      photoPath: fields[3] as String?,
      vetName: fields[4] as String?,
      healthHistory: (fields[5] as List).cast<HealthRecordModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.photoPath)
      ..writeByte(4)
      ..write(obj.vetName)
      ..writeByte(5)
      ..write(obj.healthHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
