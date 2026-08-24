// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelProgressAdapter extends TypeAdapter<LevelProgress> {
  @override
  final int typeId = 0;

  @override
  LevelProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelProgress(
      levelNumber: fields[0] as int,
      isUnlocked: fields[1] as bool,
      isCompleted: fields[2] as bool,
      starsEarned: fields[3] as int,
      bestTimeSeconds: fields[4] as int?,
      wrongTaps: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LevelProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.levelNumber)
      ..writeByte(1)
      ..write(obj.isUnlocked)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.starsEarned)
      ..writeByte(4)
      ..write(obj.bestTimeSeconds)
      ..writeByte(5)
      ..write(obj.wrongTaps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
