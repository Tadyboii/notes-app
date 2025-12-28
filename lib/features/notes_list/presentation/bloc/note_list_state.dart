part of 'note_list_bloc.dart';

@freezed
class NoteListState with _$NoteListState {
  const factory NoteListState({
    @Default(<Note>[]) List<Note> notes,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _NoteState;

  factory NoteListState.initial() => const NoteListState();
}
