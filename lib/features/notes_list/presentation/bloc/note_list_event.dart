part of 'note_list_bloc.dart';

@freezed
abstract class NoteListEvent with _$NoteListEvent {
  const factory NoteListEvent.getAllNotes() = _GetAllNotes;

  const factory NoteListEvent.searchNotes(String query) = _SearchNotes;

  const factory NoteListEvent.deleteNote(String id) = _DeleteNote;
}
