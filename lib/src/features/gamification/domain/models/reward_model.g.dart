// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardModelAdapter extends TypeAdapter<RewardModel> {
  @override
  final int typeId = 21;

  @override
  RewardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardModel(
      id: fields[0] as String,
      title: fields[1] as String,
      cost: fields[2] as double,
      iconCode: fields[3] as int,
      colorValue: fields[4] as int,
      isRedeemed: fields[5] as bool,
      redeemedDate: fields[6] as DateTime?,
      categoryId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.cost)
      ..writeByte(3)
      ..write(obj.iconCode)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.isRedeemed)
      ..writeByte(6)
      ..write(obj.redeemedDate)
      ..writeByte(7)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
