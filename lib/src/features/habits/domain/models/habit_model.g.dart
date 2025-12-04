// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 6;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      targetFrequency: fields[3] as int,
      completedDates: (fields[4] as List).cast<DateTime>(),
      currentStreak: fields[5] as int,
      bestStreak: fields[6] as int,
      colorCode: fields[7] as int,
      createdAt: fields[8] as DateTime,
      iconCode: fields[9] == null ? 57521 : fields[9] as int,
      attribute: fields[10] == null ? 'Disciplina' : fields[10] as String,
      hasReminder: fields[11] == null ? false : fields[11] as bool,
      reminderHour: fields[12] as int?,
      reminderMinute: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetFrequency)
      ..writeByte(4)
      ..write(obj.completedDates)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.bestStreak)
      ..writeByte(7)
      ..write(obj.colorCode)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.iconCode)
      ..writeByte(10)
      ..write(obj.attribute)
      ..writeByte(11)
      ..write(obj.hasReminder)
      ..writeByte(12)
      ..write(obj.reminderHour)
      ..writeByte(13)
      ..write(obj.reminderMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
