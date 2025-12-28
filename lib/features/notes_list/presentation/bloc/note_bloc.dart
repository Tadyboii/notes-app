import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/search_notes_usecase.dart';

part 'note_bloc.freezed.dart';
part 'note_event.dart';
part 'note_state.dart';

@injectable
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc(
    this.getAllNotesUseCase,
    this.searchNotesUseCase,
    this.deleteNoteUseCase,
  ) : super(NoteState.initial()) {
    on<_GetAllNotes>(_onGetAllNotes);
    on<_SearchNotes>(_onSearchNotes);
    on<_DeleteNote>(_onDeleteNote);
  }

  final GetAllNotesUseCase getAllNotesUseCase;
  final SearchNotesUseCase searchNotesUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  Future<void> _onGetAllNotes(
    _GetAllNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getAllNotesUseCase(const NoParams());
    switch (result) {
      case ResultSuccess<List<Note>, Failure>(:final value):
        emit(state.copyWith(notes: value, isLoading: false));
      case ResultFailure<List<Note>, Failure>(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onSearchNotes(
    _SearchNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await searchNotesUseCase(event.query);
    switch (result) {
      case ResultSuccess<List<Note>, Failure>(:final value):
        emit(state.copyWith(notes: value, isLoading: false));
      case ResultFailure<List<Note>, Failure>(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onDeleteNote(
    _DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await deleteNoteUseCase(event.id);
    switch (result) {
      case ResultSuccess<void, Failure>():
        add(const NoteEvent.getAllNotes());
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }
}
