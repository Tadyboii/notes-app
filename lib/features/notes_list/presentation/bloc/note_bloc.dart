import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/add_note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes.dart';
import 'package:notes_app/features/notes_list/domain/usecases/update_note.dart';

part 'note_bloc.freezed.dart';
part 'note_event.dart';
part 'note_state.dart';

@injectable
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotes getAllNotesUseCase;
  final AddNote addNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final UpdateNote updateNoteUseCase;

  NoteBloc(
    this.getAllNotesUseCase,
    this.addNoteUseCase,
    this.deleteNoteUseCase,
    this.updateNoteUseCase,
  ) : super(NoteState.initial()) {
    on<NoteEvent>((event, emit) async {
      switch (event) {
        case _GetAllNotes():
          await _getAllNotes(emit);
          break;
        case _AddNote(:final note):
          await _addNote(note, emit);
          break;
        case _UpdateNote(:final note):
          await _updateNote(note, emit);
          break;
        case _DeleteNote(:final id):
          await _deleteNote(id, emit);
          break;
      }
    });
  }

  Future<void> _getAllNotes(Emitter<NoteState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await getAllNotesUseCase(NoParams());
    switch (result) {
      case ResultSuccess<List<Note>, Failure>(:final value):
        emit(state.copyWith(notes: value, isLoading: false));
        break;

      case ResultFailure<List<Note>, Failure>(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        break;
    }
  }

  Future<void> _addNote(Note note, Emitter<NoteState> emit) async {
    final result = await addNoteUseCase(note);
    switch (result) {
      case ResultSuccess<void, Failure>():
        add(const NoteEvent.getAllNotes());
        break;

      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
        break;
    }
  }

  Future<void> _deleteNote(String id, Emitter<NoteState> emit) async {
    final result = await deleteNoteUseCase(id);
    switch (result) {
      case ResultSuccess<void, Failure>():
        add(const NoteEvent.getAllNotes());
        break;
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
        break;
    }
  }

  Future<void> _updateNote(Note note, Emitter<NoteState> emit) async {
    final result = await updateNoteUseCase(note);
    switch (result) {
      case ResultSuccess<void, Failure>():
        add(const NoteEvent.getAllNotes());
        break;
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
        break;
    }
  }
}
