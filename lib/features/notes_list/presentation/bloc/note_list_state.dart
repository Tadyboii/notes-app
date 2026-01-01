part of 'note_list_bloc.dart';

@freezed
class NoteListState with _$NoteListState {
  const factory NoteListState({
    @Default(<Note>[]) List<Note> notes,
    @Default(false) bool isLoading,
    @Default('') String query,
    String? errorMessage,
  }) = _NoteListState;

  factory NoteListState.initial() => const NoteListState();
}
