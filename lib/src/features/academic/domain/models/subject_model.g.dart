// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 11;

  @override
  SubjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      evaluations: (fields[2] as List).cast<EvaluationModel>(),
      passingGrade: fields[3] as double,
      targetGrade: fields[4] as double?,
      gradingScale: fields[5] == null ? 0 : fields[5] as int,
      totalClasses: fields[6] == null ? 0 : fields[6] as int,
      attendedClasses: fields[7] == null ? 0 : fields[7] as int,
      minAttendance: fields[8] == null ? 0.75 : fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.evaluations)
      ..writeByte(3)
      ..write(obj.passingGrade)
      ..writeByte(4)
      ..write(obj.targetGrade)
      ..writeByte(5)
      ..write(obj.gradingScale)
      ..writeByte(6)
      ..write(obj.totalClasses)
      ..writeByte(7)
      ..write(obj.attendedClasses)
      ..writeByte(8)
      ..write(obj.minAttendance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
