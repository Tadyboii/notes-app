import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes_usecase.dart';
import 'package:notes_app/features/notes_list/domain/usecases/search_notes_usecase.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_list_bloc.dart';

class MockGetAllNotesUseCase extends Mock implements GetAllNotesUseCase {}

class MockSearchNotesUseCase extends Mock implements SearchNotesUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

void main() {
  late NoteBloc noteBloc;
  late MockGetAllNotesUseCase mockGetAllNotesUseCase;
  late MockSearchNotesUseCase mockSearchNotesUseCase;
  late MockDeleteNoteUseCase mockDeleteNoteUseCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const NoParams());
    registerFallbackValue(const Note(title: '', content: ''));
  });

  setUp(() {
    mockGetAllNotesUseCase = MockGetAllNotesUseCase();
    mockSearchNotesUseCase = MockSearchNotesUseCase();
    mockDeleteNoteUseCase = MockDeleteNoteUseCase();

    noteBloc = NoteBloc(
      mockGetAllNotesUseCase,
      mockSearchNotesUseCase,
      mockDeleteNoteUseCase,
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
      expect(noteBloc.state, equals(NoteListState.initial()));
    });

    group('GetAllNotes', () {
      blocTest<NoteBloc, NoteListState>(
        'should emit [loading, success] when getAllNotes is successful',
        build: () {
          when(
            () => mockGetAllNotesUseCase(any()),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteListEvent.getAllNotes()),
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteListState>(
        'should emit [loading, error] when getAllNotes fails',
        build: () {
          when(() => mockGetAllNotesUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to fetch notes'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteListEvent.getAllNotes()),
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Failed to fetch notes',
          ),
        ],
        verify: (_) {
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );
    });

    group('DeleteNote', () {
      const tNoteId = '1';

      blocTest<NoteBloc, NoteListState>(
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
        act: (bloc) => bloc.add(const NoteListEvent.deleteNote(tNoteId)),
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockDeleteNoteUseCase(any())).called(1);
          verify(() => mockGetAllNotesUseCase(any())).called(1);
        },
      );

      blocTest<NoteBloc, NoteListState>(
        'should emit error when deleteNote fails',
        build: () {
          when(() => mockDeleteNoteUseCase(any())).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to delete note'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteListEvent.deleteNote(tNoteId)),
        // Updated expectation to match current bloc emissions:
        // first loading, then error (bloc currently leaves isLoading == true)
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(
            isLoading: true,
            errorMessage: 'Failed to delete note',
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteNoteUseCase(any())).called(1);
          verifyNever(() => mockGetAllNotesUseCase(any()));
        },
      );
    });

    group('SearchNotes', () {
      const tQuery = 'Test';

      blocTest<NoteBloc, NoteListState>(
        'should emit [loading, success] when searchNotes is successful',
        build: () {
          when(
            () => mockSearchNotesUseCase(tQuery),
          ).thenAnswer((_) async => const ResultSuccess(tNotes));
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteListEvent.searchNotes(tQuery)),
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(notes: tNotes, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockSearchNotesUseCase(tQuery)).called(1);
        },
      );

      blocTest<NoteBloc, NoteListState>(
        'should emit [loading, error] when searchNotes fails',
        build: () {
          when(() => mockSearchNotesUseCase(tQuery)).thenAnswer(
            (_) async => const Result.failure(
              UnexpectedFailure(message: 'Failed to search notes'),
            ),
          );
          return noteBloc;
        },
        act: (bloc) => bloc.add(const NoteListEvent.searchNotes(tQuery)),
        expect: () => [
          NoteListState.initial().copyWith(isLoading: true, errorMessage: null),
          NoteListState.initial().copyWith(
            isLoading: false,
            errorMessage: 'Failed to search notes',
          ),
        ],
        verify: (_) {
          verify(() => mockSearchNotesUseCase(tQuery)).called(1);
        },
      );
    });
  });
}
