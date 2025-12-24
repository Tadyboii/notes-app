import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
class NoteModel with _$NoteModel {
  @HiveType(typeId: 0)
  const factory NoteModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String content,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
}
