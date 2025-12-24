part of 'note_bloc.dart';

@freezed
class NoteState with _$NoteState {
  const factory NoteState({
    @Default(<Note>[]) List<Note> notes,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _NoteState;

  factory NoteState.initial() => const NoteState();
}
