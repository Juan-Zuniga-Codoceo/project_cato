// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationModelAdapter extends TypeAdapter<EvaluationModel> {
  @override
  final int typeId = 10;

  @override
  EvaluationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      grade: fields[2] as double,
      weight: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.grade)
      ..writeByte(3)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
