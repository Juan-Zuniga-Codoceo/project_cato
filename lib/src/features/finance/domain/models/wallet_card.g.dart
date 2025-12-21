// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletCardAdapter extends TypeAdapter<WalletCard> {
  @override
  final int typeId = 30;

  @override
  WalletCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletCard(
      id: fields[0] as String,
      name: fields[1] as String,
      bankName: fields[2] as String,
      type: fields[3] as String,
      paymentDay: fields[4] as int,
      limit: fields[5] as double,
      colorValue: fields[6] as int,
      initialBalance: fields[7] as double,
      isFavorite: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WalletCard obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bankName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.paymentDay)
      ..writeByte(5)
      ..write(obj.limit)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.initialBalance)
      ..writeByte(8)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
