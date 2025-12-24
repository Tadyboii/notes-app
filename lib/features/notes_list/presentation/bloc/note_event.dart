part of 'note_bloc.dart';

@freezed
abstract class NoteEvent with _$NoteEvent {
  const factory NoteEvent.getAllNotes() = _GetAllNotes;

  const factory NoteEvent.addNote(Note note) = _AddNote;

  const factory NoteEvent.updateNote(Note note) = _UpdateNote;

  const factory NoteEvent.deleteNote(String id) = _DeleteNote;
}
