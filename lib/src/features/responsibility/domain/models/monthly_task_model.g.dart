// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyTaskModelAdapter extends TypeAdapter<MonthlyTaskModel> {
  @override
  final int typeId = 8;

  @override
  MonthlyTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyTaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      difficulty: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyTaskModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
