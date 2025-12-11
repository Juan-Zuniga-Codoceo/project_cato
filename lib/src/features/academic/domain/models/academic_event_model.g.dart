// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AcademicEventModelAdapter extends TypeAdapter<AcademicEventModel> {
  @override
  final int typeId = 12;

  @override
  AcademicEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AcademicEventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      subjectId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AcademicEventModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.subjectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
