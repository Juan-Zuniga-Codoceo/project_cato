// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsModelAdapter extends TypeAdapter<UserStatsModel> {
  @override
  final int typeId = 7;

  @override
  UserStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStatsModel(
      totalXp: fields[0] as int,
      currentLevel: fields[1] as int,
      strengthXp: fields[2] == null ? 0 : fields[2] as int,
      intellectXp: fields[3] == null ? 0 : fields[3] as int,
      vitalityXp: fields[4] == null ? 0 : fields[4] as int,
      disciplineXp: fields[5] == null ? 0 : fields[5] as int,
      userName: fields[6] == null ? 'Guerrero' : fields[6] as String,
      avatarPath:
          fields[7] == null ? 'assets/avatars/hero_1.jpg' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserStatsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.totalXp)
      ..writeByte(1)
      ..write(obj.currentLevel)
      ..writeByte(2)
      ..write(obj.strengthXp)
      ..writeByte(3)
      ..write(obj.intellectXp)
      ..writeByte(4)
      ..write(obj.vitalityXp)
      ..writeByte(5)
      ..write(obj.disciplineXp)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.avatarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
