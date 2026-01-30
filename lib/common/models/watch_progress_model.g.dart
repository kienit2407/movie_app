// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchProgressModelAdapter extends TypeAdapter<WatchProgressModel> {
  @override
  final typeId = 1;

  @override
  WatchProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchProgressModel(
      movieId: fields[0] as String,
      episodeName: fields[1] as String,
      positionMs: (fields[2] as num).toInt(),
      durationMs: (fields[3] as num).toInt(),
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchProgressModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.movieId)
      ..writeByte(1)
      ..write(obj.episodeName)
      ..writeByte(2)
      ..write(obj.positionMs)
      ..writeByte(3)
      ..write(obj.durationMs)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
