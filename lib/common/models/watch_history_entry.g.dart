// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchHistoryEntryAdapter extends TypeAdapter<WatchHistoryEntry> {
  @override
  final typeId = 100;

  @override
  WatchHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchHistoryEntry(
      slug: fields[0] as String,
      name: fields[1] as String,
      originName: fields[2] as String,
      posterUrl: fields[3] as String,
      thumbUrl: fields[4] as String?,
      episodeCurrent: fields[5] as String,
      quality: fields[6] as String?,
      lang: fields[7] as String?,
      year: fields[8] as String?,
      rating: (fields[9] as num?)?.toDouble(),
      watchedAt: fields[10] as DateTime,
      positionMs: (fields[11] as num).toInt(),
      durationMs: (fields[12] as num).toInt(),
      type: fields[13] as String?,
      categoryId: fields[14] as String?,
      categoryName: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchHistoryEntry obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.slug)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.originName)
      ..writeByte(3)
      ..write(obj.posterUrl)
      ..writeByte(4)
      ..write(obj.thumbUrl)
      ..writeByte(5)
      ..write(obj.episodeCurrent)
      ..writeByte(6)
      ..write(obj.quality)
      ..writeByte(7)
      ..write(obj.lang)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.watchedAt)
      ..writeByte(11)
      ..write(obj.positionMs)
      ..writeByte(12)
      ..write(obj.durationMs)
      ..writeByte(13)
      ..write(obj.type)
      ..writeByte(14)
      ..write(obj.categoryId)
      ..writeByte(15)
      ..write(obj.categoryName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
