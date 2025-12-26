import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/exceptions.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:notes_app/features/notes_list/data/repositories/note_repository_impl.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';

// Mock data source
class MockNoteLocalDataSource extends Mock implements NoteLocalDataSource {}

void main() {
  late NoteRepositoryImpl repository;
  late MockNoteLocalDataSource mockDataSource;

  final now = DateTime.now();

  setUpAll(() {
    // Register fallback values for custom types
    registerFallbackValue(
      NoteModel(
        id: '',
        title: '',
        content: '',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  setUp(() {
    mockDataSource = MockNoteLocalDataSource();
    repository = NoteRepositoryImpl(mockDataSource);
  });

  group('NoteRepositoryImpl', () {
    group('getAllNotes', () {
      final testModels = [
        NoteModel(
          id: '1',
          title: 'Test Note 1',
          content: 'Content 1',
          createdAt: now,
          updatedAt: now,
        ),
        NoteModel(
          id: '2',
          title: 'Test Note 2',
          content: 'Content 2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final testNotes = [
        Note(
          id: '1',
          title: 'Test Note 1',
          content: 'Content 1',
          createdAt: now,
          updatedAt: now,
        ),
        Note(
          id: '2',
          title: 'Test Note 2',
          content: 'Content 2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      test(
        'returns success with mapped Note entities when call succeeds',
            () async {
          when(() => mockDataSource.getAllNotes())
              .thenAnswer((_) async => testModels);

          final result = await repository.getAllNotes();

          expect(result, equals(Result<List<Note>, Failure>(testNotes)));
          verify(() => mockDataSource.getAllNotes()).called(1);
        },
      );

      test('returns success with empty list when no notes exist', () async {
        when(() => mockDataSource.getAllNotes()).thenAnswer((_) async => []);

        final result = await repository.getAllNotes();

        expect(result, equals(const Result<List<Note>, Failure>([])));
        verify(() => mockDataSource.getAllNotes()).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
            () async {
          when(() => mockDataSource.getAllNotes())
              .thenThrow(const CacheException('Failed to load notes'));

          final result = await repository.getAllNotes();

          expect(result, isA<ResultFailure<List<Note>, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('CacheException'));
          expect(failure.message, contains('Failed to load notes'));
          verify(() => mockDataSource.getAllNotes()).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
            () async {
          when(() => mockDataSource.getAllNotes())
              .thenThrow(Exception('Unexpected error'));

          final result = await repository.getAllNotes();

          expect(result, isA<ResultFailure<List<Note>, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          expect(failure.message, contains('Unexpected error'));
          verify(() => mockDataSource.getAllNotes()).called(1);
        },
      );
    });

    group('addNote', () {
      final testNote = Note(
        id: '1',
        title: 'New Note',
        content: 'New Content',
        createdAt: now,
        updatedAt: now,
      );

      test('returns success when note is added successfully', () async {
        when(() => mockDataSource.addNote(any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.addNote(testNote);

        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.addNote(any())).called(1);
      });

      test('calls data source with correct NoteModel', () async {
        final expectedModel = NoteModel(
          id: '1',
          title: 'New Note',
          content: 'New Content',
          createdAt: now,
          updatedAt: now,
        );
        when(() => mockDataSource.addNote(any()))
            .thenAnswer((_) async => Future.value());

        await repository.addNote(testNote);

        verify(() => mockDataSource.addNote(expectedModel)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
            () async {
          when(() => mockDataSource.addNote(any()))
              .thenThrow(const CacheException('Failed to save note'));

          final result = await repository.addNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('CacheException'));
          expect(failure.message, contains('Failed to save note'));
          verify(() => mockDataSource.addNote(any())).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
            () async {
          when(() => mockDataSource.addNote(any()))
              .thenThrow(Exception('Unexpected error'));

          final result = await repository.addNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.addNote(any())).called(1);
        },
      );
    });

    group('updateNote', () {
      final testNote = Note(
        id: '1',
        title: 'Updated Note',
        content: 'Updated Content',
        createdAt: now,
        updatedAt: now,
      );

      test('returns success when note is updated successfully', () async {
        when(() => mockDataSource.updateNote(any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.updateNote(testNote);

        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.updateNote(any())).called(1);
      });

      test('calls data source with correct NoteModel', () async {
        final expectedModel = NoteModel(
          id: '1',
          title: 'Updated Note',
          content: 'Updated Content',
          createdAt: now,
          updatedAt: now,
        );
        when(() => mockDataSource.updateNote(any()))
            .thenAnswer((_) async => Future.value());

        await repository.updateNote(testNote);

        verify(() => mockDataSource.updateNote(expectedModel)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
            () async {
          when(() => mockDataSource.updateNote(any()))
              .thenThrow(const CacheException('Failed to update note'));

          final result = await repository.updateNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('CacheException'));
          expect(failure.message, contains('Failed to update note'));
          verify(() => mockDataSource.updateNote(any())).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
            () async {
          when(() => mockDataSource.updateNote(any()))
              .thenThrow(Exception('Unexpected error'));

          final result = await repository.updateNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.updateNote(any())).called(1);
        },
      );
    });

    group('deleteNote', () {
      const testNoteId = '1';

      test('returns success when note is deleted successfully', () async {
        when(() => mockDataSource.deleteNote(any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.deleteNote(testNoteId);

        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test('calls data source with correct note id', () async {
        when(() => mockDataSource.deleteNote(any()))
            .thenAnswer((_) async => Future.value());

        await repository.deleteNote(testNoteId);

        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
            () async {
          when(() => mockDataSource.deleteNote(any()))
              .thenThrow(const CacheException('Failed to delete note'));

          final result = await repository.deleteNote(testNoteId);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('CacheException'));
          expect(failure.message, contains('Failed to delete note'));
          verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
            () async {
          when(() => mockDataSource.deleteNote(any()))
              .thenThrow(Exception('Unexpected error'));

          final result = await repository.deleteNote(testNoteId);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
        },
      );
    });
  });
}
