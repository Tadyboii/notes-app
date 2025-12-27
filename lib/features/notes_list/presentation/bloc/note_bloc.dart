import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/add_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/search_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/update_note_usecase.dart';

part 'note_bloc.freezed.dart';
part 'note_event.dart';
part 'note_state.dart';

@injectable
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc(
    this.getAllNotesUseCase,
    this.searchNotesUseCase,
    this.addNoteUseCase,
    this.deleteNoteUseCase,
    this.updateNoteUseCase,
  ) : super(NoteState.initial()) {
    on<NoteEvent>((event, emit) async {
      switch (event) {
        case _GetAllNotes():
          await _getAllNotes(emit);
        case _SearchNotes(:final query):
          await _searchNotes(query, emit);
        case _AddNote(:final note):
          await _addNote(note, emit);
        case _UpdateNote(:final note):
          await _updateNote(note, emit);
        case _DeleteNote(:final id):
          await _deleteNote(id, emit);
      }
    });
  }

  final GetAllNotesUseCase getAllNotesUseCase;
  final SearchNotesUseCase searchNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;

  String? _currentSearchQuery;
  Timer? _debounceTimer;
  int _searchVersion = 0;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _getAllNotes(Emitter<NoteState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    _currentSearchQuery = null;
    final result = await getAllNotesUseCase(const NoParams());
    switch (result) {
      case ResultSuccess<List<Note>, Failure>(:final value):
        emit(state.copyWith(notes: value, isLoading: false));

      case ResultFailure<List<Note>, Failure>(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _searchNotes(String query, Emitter<NoteState> emit) async {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _currentSearchQuery = null;
      await _getAllNotes(emit);
      return;
    }

    _searchVersion++;
    final searchVersion = _searchVersion;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchVersion == searchVersion) {
        _currentSearchQuery = query;
        // ignore: unawaited_futures
        _performSearch(query, emit, searchVersion);
      }
    });
  }

  Future<void> _performSearch(
    String query,
    Emitter<NoteState> emit,
    int searchVersion,
  ) async {
    // Check if this search is still relevant
    if (_searchVersion != searchVersion) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await searchNotesUseCase(query);

    // Check again if the query is still current
    if (_searchVersion != searchVersion) {
      return;
    }

    switch (result) {
      case ResultSuccess<List<Note>, Failure>(:final value):
        emit(state.copyWith(notes: value, isLoading: false));

      case ResultFailure<List<Note>, Failure>(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _addNote(Note note, Emitter<NoteState> emit) async {
    if (note.title.trim().isEmpty && note.content.trim().isEmpty) {
      return;
    }

    final result = await addNoteUseCase(note);
    switch (result) {
      case ResultSuccess<void, Failure>():
        if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
          add(NoteEvent.searchNotes(_currentSearchQuery!));
        } else {
          add(const NoteEvent.getAllNotes());
        }

      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _deleteNote(String id, Emitter<NoteState> emit) async {
    final result = await deleteNoteUseCase(id);
    switch (result) {
      case ResultSuccess<void, Failure>():
        if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
          add(NoteEvent.searchNotes(_currentSearchQuery!));
        } else {
          add(const NoteEvent.getAllNotes());
        }
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _updateNote(Note note, Emitter<NoteState> emit) async {
    if (note.title.trim().isEmpty && note.content.trim().isEmpty) {
      return;
    }

    final existingNote = state.notes.firstWhere(
      (n) => n.id == note.id,
      orElse: () => note,
    );

    if (note.title.trim() == existingNote.title.trim() &&
        note.content.trim() == existingNote.content.trim()) {
      return;
    }

    final result = await updateNoteUseCase(note);
    switch (result) {
      case ResultSuccess<void, Failure>():
        if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
          add(NoteEvent.searchNotes(_currentSearchQuery!));
        } else {
          add(const NoteEvent.getAllNotes());
        }
      case ResultFailure<void, Failure>(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }
}
