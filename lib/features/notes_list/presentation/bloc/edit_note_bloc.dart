import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/add_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/update_note_usecase.dart';

part 'edit_note_bloc.freezed.dart';
part 'edit_note_event.dart';
part 'edit_note_state.dart';

@injectable
class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  EditNoteBloc(
    @factoryParam Note? initialNote,
    this.addNoteUseCase,
    this.updateNoteUseCase,
  ) : super(EditNoteState.initial(initialNote)) {
    on<_TitleChanged>(_onTitleChanged);
    on<_ContentChanged>(_onContentChanged);
    on<_SaveNote>(_onSaveNote);
    on<_DeleteNote>(_onDeleteNote);
    on<_ResetState>(_onResetState);
    on<_AddNote>(_onAddNote);
    on<_UpdateNote>(_onUpdateNote);
  }

  final AddNoteUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;

  void _onTitleChanged(
    _TitleChanged event,
    Emitter<EditNoteState> emit,
  ) {
    emit(
      state.copyWith(
        titleDraft: event.title,
        isEdited: event.title != state.initialTitle,
        isEmpty: event.title.isEmpty && state.contentDraft.isEmpty,
      ),
    );
  }

  void _onContentChanged(
    _ContentChanged event,
    Emitter<EditNoteState> emit,
  ) {
    emit(
      state.copyWith(
        contentDraft: event.content,
        isEdited: event.content != state.initialContent,
        isEmpty: state.titleDraft.isEmpty && event.content.isEmpty,
      ),
    );
  }

  void _onSaveNote(
    _SaveNote event,
    Emitter<EditNoteState> emit,
  ) {
    emit(state.copyWith(isSaved: true));
  }

  void _onDeleteNote(
    _DeleteNote event,
    Emitter<EditNoteState> emit,
  ) {
    emit(state.copyWith(isDeleting: true));
  }

  void _onResetState(
    _ResetState event,
    Emitter<EditNoteState> emit,
  ) {
    emit(
      state.copyWith(
        initialTitle: state.titleDraft,
        initialContent: state.contentDraft,
        isSaved: false,
        isEdited: false,
        isNewNote: false,
      ),
    );
  }

  Future<void> _onAddNote(
    _AddNote event,
    Emitter<EditNoteState> emit,
  ) async {
    final result = await addNoteUseCase(event.note);
    switch (result) {
      case ResultSuccess<Note, Failure>(:final value):
        emit(state.copyWith(noteId: value.id!));
      case ResultFailure<Note, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _onUpdateNote(
    _UpdateNote event,
    Emitter<EditNoteState> emit,
  ) async {
    final result = await updateNoteUseCase(event.note);
    switch (result) {
      case ResultSuccess<void, Failure>():
        break;
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }
}
