import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';

extension NoteMapper on NoteModel {
  Note toDomain() {
    return Note(id: id, title: title, content: content);
  }
}

extension NoteModelMapper on Note {
  NoteModel toModel() {
    return NoteModel(id: id ?? '', title: title, content: content);
  }
}
