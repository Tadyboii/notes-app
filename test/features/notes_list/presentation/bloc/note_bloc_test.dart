import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/add_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/search_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/update_note_usecase.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';

class MockGetAllNotesUseCase extends Mock implements GetAllNotesUseCase {}

class MockSearchNotesUseCase extends Mock implements SearchNotesUseCase {}

class MockAddNoteUseCase extends Mock implements AddNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

void main() {
  late NoteBloc noteBloc;
  late MockGetAllNotesUseCase mockGetAllNotesUseCase;
  late MockSearchNotesUseCase mockSearchNotesUseCase;
  late MockAddNoteUseCase mockAddNoteUseCase;
  late MockDeleteNoteUseCase mockDeleteNoteUseCase;
  late MockUpdateNoteUseCase mockUpdateNoteUseCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const NoParams());
    registerFallbackValue(const Note(title: '', content: ''));
  });

  setUp(() {
    mockGetAllNotesUseCase = MockGetAllNotesUseCase();
    mockSearchNotesUseCase = MockSearchNotesUseCase();
    mockAddNoteUseCase = MockAddNoteUseCase();
    mockDeleteNoteUseCase = MockDeleteNoteUseCase();
    mockUpdateNoteUseCase = MockUpdateNoteUseCase();

    noteBloc = NoteBloc(
      mockGetAllNotesUseCase,
      mockSearchNotesUseCase,
      mockAddNoteUseCase,
      mockDeleteNoteUseCase,
      mockUpdateNoteUseCase,
    );
  });

  tearDown(() async {
    await noteBloc.close();
  });

  group('NoteBloc', () {
    const tNote = Note(
      id: '1',
      title: 'Test Note',
      content: 'Test Content',
    );

    const tNotes = [tNote];

    test('initial state should be NoteState.initial()', () {
      expect(noteBloc.state, equals(NoteState.initial()));
    });

    group('GetAllNotes', () {
      blocTest<NoteBloc, NoteState>(
        'should emit [loading, success] when getAllNotes is successful',
        build: () {
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.getAllNotes()),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should emit [loading, error] when getAllNotes fails',
        build: () {
          when(() => mockGetAllNotesUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to fetch notes'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.getAllNotes()),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Failed to fetch notes',
          ),
        ],
        verify: (_) {
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );
    });

    group('AddNote', () {
      blocTest<NoteBloc, NoteState>(
        'should call getAllNotes when addNote is successful',
        build: () {
          when(
            () => mockAddNoteUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(null));
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.addNote(tNote)),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockAddNoteUseCase(any())).called(1);
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should emit error when addNote fails',
        build: () {
          when(() => mockAddNoteUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to add note'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.addNote(tNote)),
        expect: () => [
          NoteState.initial().copyWith(errorMessage: 'Failed to add note'),
        ],
        verify: (_) {
          verify(() => mockAddNoteUseCase(any())).called(1);
          verifyNever(() => mockGetAllNotesUseCase(any()));
        },
      );
    });

    group('UpdateNote', () {
      blocTest<NoteBloc, NoteState>(
        'should call getAllNotes when updateNote is successful',
        build: () {
          when(
            () => mockUpdateNoteUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(null));
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.updateNote(tNote)),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockUpdateNoteUseCase(any())).called(1);
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should emit error when updateNote fails',
        build: () {
          when(() => mockUpdateNoteUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to update note'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.updateNote(tNote)),
        expect: () => [
          NoteState.initial().copyWith(errorMessage: 'Failed to update note'),
        ],
        verify: (_) {
          verify(() => mockUpdateNoteUseCase(any())).called(1);
          verifyNever(() => mockGetAllNotesUseCase(any()));
        },
      );
    });

    group('DeleteNote', () {
      const tNoteId = '1';

      blocTest<NoteBloc, NoteState>(
        'should call getAllNotes when deleteNote is successful',
        build: () {
          when(
            () => mockDeleteNoteUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(null));
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.deleteNote(tNoteId)),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockDeleteNoteUseCase(any())).called(1);
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should emit error when deleteNote fails',
        build: () {
          when(() => mockDeleteNoteUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to delete note'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.deleteNote(tNoteId)),
        expect: () => [
          NoteState.initial().copyWith(errorMessage: 'Failed to delete note'),
        ],
        verify: (_) {
          verify(() => mockDeleteNoteUseCase(any())).called(1);
          verifyNever(() => mockGetAllNotesUseCase(any()));
        },
      );
    });

    group('SearchNotes', () {
      const tQuery = 'Test';

      blocTest<NoteBloc, NoteState>(
        'should emit [loading, success] when searchNotes is successful',
        build: () {
          when(
            () => mockSearchNotesUseCase(tQuery),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.searchNotes(tQuery)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockSearchNotesUseCase(tQuery)).called(1);
        },
      );
      blocTest<NoteBloc, NoteState>(
        'should emit [loading, error] when searchNotes fails',
        build: () {
          when(() => mockSearchNotesUseCase(tQuery)).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to search notes'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.searchNotes(tQuery)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Failed to search notes',
          ),
        ],
        verify: (_) {
          verify(() => mockSearchNotesUseCase(tQuery)).called(1);
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should call getAllNotes when search query is empty',
        build: () {
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteEvent.searchNotes('')),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockGetAllNotesUseCase(any())).called(1);
          verifyNever(() => mockSearchNotesUseCase(any()));
        },
      );

      blocTest<NoteBloc, NoteState>(
        'should debounce multiple search events',
        build: () {
          when(
            () => mockSearchNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) {
          bloc.add(const NoteEvent.searchNotes('T'));
          bloc.add(const NoteEvent.searchNotes('Te'));
          bloc.add(const NoteEvent.searchNotes('Tes'));
          bloc.add(const NoteEvent.searchNotes('Test'));
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          NoteState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          // Only the last search should be called after debounce
          verify(() => mockSearchNotesUseCase('Test')).called(1);
          verifyNever(() => mockSearchNotesUseCase('T'));
          verifyNever(() => mockSearchNotesUseCase('Te'));
          verifyNever(() => mockSearchNotesUseCase('Tes'));
        },
      );
    });
  });
}
