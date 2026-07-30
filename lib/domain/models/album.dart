import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

@freezed
abstract class Album with _$Album {
  const factory Album({
    required String id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? year,
    String? authorsText,
    String? shareUrl,
    int? timestamp,
    int? bookmarkedAt,
    String? otherInfo,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
