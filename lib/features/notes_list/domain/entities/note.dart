import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';

@freezed
abstract class Note with _$Note {
  const factory Note({
    String? id,
    required String title,
    required String content,
  }) = _Note;
}
