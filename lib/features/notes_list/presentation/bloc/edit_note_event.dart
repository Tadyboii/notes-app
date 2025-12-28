part of 'edit_note_bloc.dart';

@freezed
abstract class EditNoteEvent with _$EditNoteEvent {
  const factory EditNoteEvent.titleChanged(String title) = _TitleChanged;

  const factory EditNoteEvent.contentChanged(String content) = _ContentChanged;

  const factory EditNoteEvent.saveNote() = _SaveNote;

  const factory EditNoteEvent.deleteNote() = _DeleteNote;

  const factory EditNoteEvent.resetState() = _ResetState;

  const factory EditNoteEvent.addNote(Note note) = _AddNote;

  const factory EditNoteEvent.updateNote(Note note) = _UpdateNote;
}
