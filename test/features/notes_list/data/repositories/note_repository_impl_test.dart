import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/exceptions.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:notes_app/features/notes_list/data/repositories/note_repository_impl.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/mapper/note_mapper.dart';
import 'package:uuid/uuid.dart';

class MockNoteLocalDataSource extends Mock implements NoteLocalDataSource {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late NoteRepositoryImpl repository;
  late MockNoteLocalDataSource mockDataSource;
  late MockUuid mockUuid;

  final now = DateTime.now();

  setUpAll(() {
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
    mockUuid = MockUuid();
    repository = NoteRepositoryImpl(mockDataSource, mockUuid);
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

      final testNotes = testModels.map((m) => m.toDomain()).toList();

      test(
        'returns success with mapped Note entities when call succeeds',
        () async {
          when(
            () => mockDataSource.getAllNotes(),
          ).thenAnswer((_) async => testModels);

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
        'returns CacheFailure when data source throws CacheException',
        () async {
          when(
            () => mockDataSource.getAllNotes(),
          ).thenThrow(const CacheException('Failed to load notes'));

          final result = await repository.getAllNotes();

          expect(result, isA<ResultFailure<List<Note>, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to load notes');
          verify(() => mockDataSource.getAllNotes()).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
        () async {
          when(
            () => mockDataSource.getAllNotes(),
          ).thenThrow(Exception('Unexpected error'));

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
      final inputNote = Note(
        id: 'ignored',
        title: 'New Note',
        content: 'New Content',
        createdAt: now,
        updatedAt: now,
      );

      test('adds note and returns created Note entity', () async {
        const generatedId = 'uuid-1234';
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(
          () => mockDataSource.addNote(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.addNote(inputNote);

        final captured = verify(
          () => mockDataSource.addNote(captureAny()),
        ).captured;
        final capturedModel = captured.first as NoteModel;

        expect(capturedModel.id, generatedId);
        expect(capturedModel.title, inputNote.title);
        expect(capturedModel.content, inputNote.content);

        expect(result, equals(Result<Note, Failure>(capturedModel.toDomain())));
        verify(() => mockUuid.v4()).called(1);
      });

      test(
        'returns CacheFailure when data source throws CacheException',
        () async {
          when(() => mockUuid.v4()).thenReturn('uuid-1');
          when(
            () => mockDataSource.addNote(any()),
          ).thenThrow(const CacheException('Failed to save note'));

          final result = await repository.addNote(inputNote);

          expect(result, isA<ResultFailure<Note, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to save note');
          verify(() => mockDataSource.addNote(any())).called(1);
          verify(() => mockUuid.v4()).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
        () async {
          when(() => mockUuid.v4()).thenReturn('uuid-1');
          when(
            () => mockDataSource.addNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          final result = await repository.addNote(inputNote);

          expect(result, isA<ResultFailure<Note, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.addNote(any())).called(1);
          verify(() => mockUuid.v4()).called(1);
        },
      );
    });

    group('updateNote', () {
      final testNote = Note(
        id: '1',
        title: 'Updated Note',
        content: 'Updated Content',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );

      test('returns success when note is updated successfully', () async {
        final oldModel = NoteModel(
          id: '1',
          title: 'Old Title',
          content: 'Old Content',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );
        when(
          () => mockDataSource.getNote(any()),
        ).thenAnswer((_) async => oldModel);
        when(
          () => mockDataSource.updateNote(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.updateNote(testNote);

        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.getNote(testNote.id!)).called(1);
        verify(() => mockDataSource.updateNote(any())).called(1);
      });

      test('calls data source with correct NoteModel', () async {
        final oldModel = NoteModel(
          id: '1',
          title: 'Old Title',
          content: 'Old Content',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );
        when(
          () => mockDataSource.getNote(any()),
        ).thenAnswer((_) async => oldModel);
        when(
          () => mockDataSource.updateNote(any()),
        ).thenAnswer((_) async => Future.value());

        await repository.updateNote(testNote);

        final captured = verify(
          () => mockDataSource.updateNote(captureAny()),
        ).captured;
        final updatedModel = captured.first as NoteModel;

        expect(updatedModel.id, oldModel.id);
        expect(updatedModel.title, testNote.title);
        expect(updatedModel.content, testNote.content);
        expect(updatedModel.createdAt, oldModel.createdAt);
        expect(updatedModel.updatedAt.isAfter(oldModel.updatedAt), isTrue);

        verify(() => mockDataSource.getNote(testNote.id!)).called(1);
      });

      test(
        'returns CacheFailure when data source throws CacheException',
        () async {
          when(
            () => mockDataSource.getNote(any()),
          ).thenThrow(const CacheException('Failed to update note'));

          final result = await repository.updateNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to update note');
          verify(() => mockDataSource.getNote(any())).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
        () async {
          when(
            () => mockDataSource.getNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          final result = await repository.updateNote(testNote);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.getNote(any())).called(1);
        },
      );
    });

    group('deleteNote', () {
      const testNoteId = '1';

      test('returns success when note is deleted successfully', () async {
        when(
          () => mockDataSource.deleteNote(any()),
        ).thenAnswer((_) async => Future.value());

        final result = await repository.deleteNote(testNoteId);

        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test('calls data source with correct note id', () async {
        when(
          () => mockDataSource.deleteNote(any()),
        ).thenAnswer((_) async => Future.value());

        await repository.deleteNote(testNoteId);

        verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
      });

      test(
        'returns CacheFailure when data source throws CacheException',
        () async {
          when(
            () => mockDataSource.deleteNote(any()),
          ).thenThrow(const CacheException('Failed to delete note'));

          final result = await repository.deleteNote(testNoteId);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to delete note');
          verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
        () async {
          when(
            () => mockDataSource.deleteNote(any()),
          ).thenThrow(Exception('Unexpected error'));

          final result = await repository.deleteNote(testNoteId);

          expect(result, isA<ResultFailure<void, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.deleteNote(testNoteId)).called(1);
        },
      );
    });

    group('searchNotes', () {
      const testQuery = 'Test';
      final testModels = [
        NoteModel(
          id: '1',
          title: 'Test Note 1',
          content: 'Content 1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final testNotes = testModels.map((m) => m.toDomain()).toList();

      test(
        'returns success with mapped Note entities when call succeeds',
        () async {
          when(
            () => mockDataSource.searchNotes(testQuery),
          ).thenAnswer((_) async => testModels);

          final result = await repository.searchNotes(testQuery);

          expect(result, equals(Result<List<Note>, Failure>(testNotes)));
          verify(() => mockDataSource.searchNotes(testQuery)).called(1);
        },
      );

      test(
        'returns success with empty list when no matching notes exist',
        () async {
          when(
            () => mockDataSource.searchNotes(testQuery),
          ).thenAnswer((_) async => []);

          final result = await repository.searchNotes(testQuery);

          expect(result, equals(const Result<List<Note>, Failure>([])));
          verify(() => mockDataSource.searchNotes(testQuery)).called(1);
        },
      );

      test(
        'returns CacheFailure when data source throws CacheException',
        () async {
          when(
            () => mockDataSource.searchNotes(testQuery),
          ).thenThrow(const CacheException('Failed to search notes'));

          final result = await repository.searchNotes(testQuery);

          expect(result, isA<ResultFailure<List<Note>, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to search notes');
          verify(() => mockDataSource.searchNotes(testQuery)).called(1);
        },
      );

      test(
        'returns UnexpectedFailure when data source throws generic exception',
        () async {
          when(
            () => mockDataSource.searchNotes(testQuery),
          ).thenThrow(Exception('Unexpected error'));

          final result = await repository.searchNotes(testQuery);

          expect(result, isA<ResultFailure<List<Note>, Failure>>());
          final failure = (result as ResultFailure).failure;
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Exception'));
          verify(() => mockDataSource.searchNotes(testQuery)).called(1);
        },
      );
    });
  });
}
