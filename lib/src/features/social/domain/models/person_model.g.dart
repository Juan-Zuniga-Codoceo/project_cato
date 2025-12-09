// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonModelAdapter extends TypeAdapter<PersonModel> {
  @override
  final int typeId = 9;

  @override
  PersonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonModel(
      id: fields[0] as String,
      name: fields[1] as String,
      relationship: fields[2] as String,
      birthday: fields[3] as DateTime?,
      anniversary: fields[4] as DateTime?,
      photoPath: fields[5] as String?,
      giftIdeas: (fields[6] as List).cast<String>(),
      contactFrequency: fields[7] as int,
      lastContactDate: fields[8] as DateTime?,
      isFavorite: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PersonModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.anniversary)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.giftIdeas)
      ..writeByte(7)
      ..write(obj.contactFrequency)
      ..writeByte(8)
      ..write(obj.lastContactDate)
      ..writeByte(9)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
