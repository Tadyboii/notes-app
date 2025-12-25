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

  setUpAll(() {
    // Register fallback values for custom types
    registerFallbackValue(
      const NoteModel(
        id: '',
        title: '',
        content: '',
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
        const NoteModel(
          id: '1',
          title: 'Test Note 1',
          content: 'Content 1',
        ),
        const NoteModel(
          id: '2',
          title: 'Test Note 2',
          content: 'Content 2',
        ),
      ];

      final testNotes = [
        const Note(
          id: '1',
          title: 'Test Note 1',
          content: 'Content 1',
        ),
        const Note(
          id: '2',
          title: 'Test Note 2',
          content: 'Content 2',
        ),
      ];

      test(
        'returns success with mapped Note entities when call succeeds',
        () async {
          // Arrange
          when(
            () => mockDataSource.getAllNotes(),
          ).thenAnswer((_) async => testModels);

          // Act
          final result = await repository.getAllNotes();

          // Assert
          expect(result, equals(Result<List<Note>, Failure>(testNotes)));
          verify(() => mockDataSource.getAllNotes()).called(1);
        },
      );

      test('returns success with empty list when no notes exist', () async {
        // Arrange
        when(() => mockDataSource.getAllNotes()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllNotes();

        // Assert
        expect(result, equals(const Result<List<Note>, Failure>([])));
        verify(() => mockDataSource.getAllNotes()).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
        () async {
          // Arrange
          when(
            () => mockDataSource.getAllNotes(),
          ).thenThrow(const CacheException('Failed to load notes'));

          // Act
          final result = await repository.getAllNotes();

          // Assert
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
          // Arrange
          when(
            () => mockDataSource.getAllNotes(),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await repository.getAllNotes();

          // Assert
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
      const testNote = Note(
        id: '1',
        title: 'New Note',
        content: 'New Content',
      );

      test('returns success when note is added successfully', () async {
        // Arrange
        when(
          () => mockDataSource.addNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.addNote(testNote);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.addNote(any())).called(1);
      });

      test('calls data source with correct NoteModel', () async {
        // Arrange
        const expectedModel = NoteModel(
          id: '1',
          title: 'New Note',
          content: 'New Content',
        );
        when(
          () => mockDataSource.addNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.addNote(testNote);

        // Assert
        verify(() => mockDataSource.addNote(expectedModel)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
        () async {
          // Arrange
          when(
            () => mockDataSource.addNote(any()),
          ).thenThrow(const CacheException('Failed to save note'));

          // Act
          final result = await repository.addNote(testNote);

          // Assert
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
          // Arrange
          when(
            () => mockDataSource.addNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await repository.addNote(testNote);

          // Assert
          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.addNote(any())).called(1);
        },
      );
    });

    group('updateNote', () {
      const testNote = Note(
        id: '1',
        title: 'Updated Note',
        content: 'Updated Content',
      );

      test('returns success when note is updated successfully', () async {
        // Arrange
        when(
          () => mockDataSource.updateNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.updateNote(testNote);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.updateNote(any())).called(1);
      });

      test('calls data source with correct NoteModel', () async {
        // Arrange
        const expectedModel = NoteModel(
          id: '1',
          title: 'Updated Note',
          content: 'Updated Content',
        );
        when(
          () => mockDataSource.updateNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.updateNote(testNote);

        // Assert
        verify(() => mockDataSource.updateNote(expectedModel)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
        () async {
          // Arrange
          when(
            () => mockDataSource.updateNote(any()),
          ).thenThrow(const CacheException('Failed to update note'));

          // Act
          final result = await repository.updateNote(testNote);

          // Assert
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
          // Arrange
          when(
            () => mockDataSource.updateNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await repository.updateNote(testNote);

          // Assert
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
        // Arrange
        when(
          () => mockDataSource.deleteNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.deleteNote(testNoteId);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test('calls data source with correct note id', () async {
        // Arrange
        when(
          () => mockDataSource.deleteNote(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.deleteNote(testNoteId);

        // Assert
        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test(
        'returns UnexpectedFailure when data source throws CacheException',
        () async {
          // Arrange
          when(
            () => mockDataSource.deleteNote(any()),
          ).thenThrow(const CacheException('Failed to delete note'));

          // Act
          final result = await repository.deleteNote(testNoteId);

          // Assert
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
          // Arrange
          when(
            () => mockDataSource.deleteNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          final result = await repository.deleteNote(testNoteId);

          // Assert
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
