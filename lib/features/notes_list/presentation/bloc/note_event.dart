part of 'note_bloc.dart';

@freezed
abstract class NoteEvent with _$NoteEvent {
  const factory NoteEvent.getAllNotes() = _GetAllNotes;

  const factory NoteEvent.searchNotes(String query) = _SearchNotes;

  const factory NoteEvent.deleteNote(String id) = _DeleteNote;
}
