// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_movie_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteMovieEntryAdapter extends TypeAdapter<FavoriteMovieEntry> {
  @override
  final typeId = 101;

  @override
  FavoriteMovieEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMovieEntry(
      slug: fields[0] as String,
      name: fields[1] as String,
      originName: fields[2] as String,
      posterUrl: fields[3] as String,
      episodeCurrent: fields[4] as String,
      quality: fields[5] as String,
      lang: fields[6] as String,
      year: (fields[7] as num).toInt(),
      rating: (fields[8] as num?)?.toDouble(),
      addedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMovieEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.slug)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.originName)
      ..writeByte(3)
      ..write(obj.posterUrl)
      ..writeByte(4)
      ..write(obj.episodeCurrent)
      ..writeByte(5)
      ..write(obj.quality)
      ..writeByte(6)
      ..write(obj.lang)
      ..writeByte(7)
      ..write(obj.year)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMovieEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
