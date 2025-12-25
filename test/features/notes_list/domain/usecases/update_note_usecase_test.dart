import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:notes_app/features/notes_list/domain/usecases/update_note_usecase.dart';

// Mock repository
class MockNoteRepository extends Mock implements INoteRepository {}

void main() {
  late UpdateNoteUseCase useCase;
  late MockNoteRepository mockRepository;

  setUpAll(() {
    // Register fallback value for Note type
    registerFallbackValue(
      const Note(
        title: '',
        content: '',
      ),
    );
  });

  setUp(() {
    mockRepository = MockNoteRepository();
    useCase = UpdateNoteUseCase(mockRepository);
  });

  group('UpdateNoteUseCase', () {
    group('call', () {
      const testNote = Note(
        id: '1',
        title: 'Updated Note',
        content: 'Updated Content',
      );

      const testNoteWithoutId = Note(
        title: 'Note Without ID',
        content: 'Content',
      );

      test(
        'returns success when note is updated successfully',
        () async {
          // Arrange
          when(
            () => mockRepository.updateNote(any()),
          ).thenAnswer((_) async => const Result(null));

          // Act
          final result = await useCase.call(testNote);

          // Assert
          expect(result, equals(const Result<void, Failure>(null)));
          verify(() => mockRepository.updateNote(testNote)).called(1);
        },
      );

      test('returns success when updating note with empty content', () async {
        // Arrange
        const noteWithEmptyContent = Note(
          id: '2',
          title: 'Title Only',
          content: '',
        );
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result(null));

        // Act
        final result = await useCase.call(noteWithEmptyContent);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockRepository.updateNote(noteWithEmptyContent)).called(1);
      });

      test('returns success when updating note with empty title', () async {
        // Arrange
        const noteWithEmptyTitle = Note(
          id: '3',
          title: '',
          content: 'Content Only',
        );
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result(null));

        // Act
        final result = await useCase.call(noteWithEmptyTitle);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockRepository.updateNote(noteWithEmptyTitle)).called(1);
      });

      test('returns success when updating note without id', () async {
        // Arrange
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result(null));

        // Act
        final result = await useCase.call(testNoteWithoutId);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockRepository.updateNote(testNoteWithoutId)).called(1);
      });

      test('returns ServerFailure when repository call fails', () async {
        // Arrange
        const failure = ServerFailure(message: 'Failed to update note');
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.updateNote(testNote)).called(1);
      });

      test('returns CacheFailure when local storage fails', () async {
        // Arrange
        const failure = CacheFailure(message: 'Failed to update note in cache');
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.updateNote(testNote)).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          // Arrange
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.updateNote(any()),
          ).thenAnswer((_) async => const Result.failure(failure));

          // Act
          final result = await useCase.call(testNote);

          // Assert
          expect(
            result,
            equals(const ResultFailure<void, Failure>(failure)),
          );
          verify(() => mockRepository.updateNote(testNote)).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        const failure = UnexpectedFailure(message: 'Unexpected error occurred');
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.updateNote(testNote)).called(1);
      });

      test('returns failure when note id does not exist', () async {
        // Arrange
        const failure = ServerFailure(message: 'Note not found');
        when(
          () => mockRepository.updateNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.updateNote(testNote)).called(1);
      });
    });
  });
}
