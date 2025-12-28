part of 'edit_note_bloc.dart';

@freezed
class EditNoteState with _$EditNoteState {
  const factory EditNoteState({
    @Default('') String titleDraft,
    @Default('') String contentDraft,
    @Default(false) bool isSaved,
    @Default(false) bool isDeleting,
    @Default(true) bool isNewNote,
    @Default(false) bool isEdited,
    @Default('') String initialTitle,
    @Default('') String initialContent,
    @Default('') String noteId,
    @Default(false) bool isEmpty,
    String? errorMessage,
  }) = _EditNoteState;

  factory EditNoteState.initial(Note? note) => EditNoteState(
    titleDraft: note?.title ?? '',
    contentDraft: note?.content ?? '',
    isNewNote: note == null,
    initialContent: note?.content ?? '',
    initialTitle: note?.title ?? '',
    noteId: note?.id ?? '',
  );
}
