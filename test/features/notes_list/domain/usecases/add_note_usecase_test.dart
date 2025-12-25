import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:notes_app/features/notes_list/domain/usecases/add_note_usecase.dart';

// Mock repository
class MockNoteRepository extends Mock implements INoteRepository {}

void main() {
  late AddNoteUseCase useCase;
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
    useCase = AddNoteUseCase(mockRepository);
  });

  group('AddNoteUseCase', () {
    group('call', () {
      const testNote = Note(
        title: 'Test Note',
        content: 'Test Content',
      );

      test(
        'returns success when note is added successfully',
        () async {
          // Arrange
          when(
            () => mockRepository.addNote(any()),
          ).thenAnswer((_) async => const Result(null));

          // Act
          final result = await useCase.call(testNote);

          // Assert
          expect(result, equals(const Result<void, Failure>(null)));
          verify(() => mockRepository.addNote(testNote)).called(1);
        },
      );

      test('returns success when adding note with empty content', () async {
        // Arrange
        const noteWithEmptyContent = Note(
          title: 'Title Only',
          content: '',
        );
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result(null));

        // Act
        final result = await useCase.call(noteWithEmptyContent);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockRepository.addNote(noteWithEmptyContent)).called(1);
      });

      test('returns success when adding note with empty title', () async {
        // Arrange
        const noteWithEmptyTitle = Note(
          title: '',
          content: 'Content Only',
        );
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result(null));

        // Act
        final result = await useCase.call(noteWithEmptyTitle);

        // Assert
        expect(result, equals(const Result<void, Failure>(null)));
        verify(() => mockRepository.addNote(noteWithEmptyTitle)).called(1);
      });

      test('returns failure when repository call fails', () async {
        // Arrange
        const failure = ServerFailure(message: 'Failed to add note');
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.addNote(testNote)).called(1);
      });

      test('returns CacheFailure when local storage fails', () async {
        // Arrange
        const failure = CacheFailure(message: 'Failed to save note locally');
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.addNote(testNote)).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          // Arrange
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.addNote(any()),
          ).thenAnswer((_) async => const Result.failure(failure));

          // Act
          final result = await useCase.call(testNote);

          // Assert
          expect(
            result,
            equals(const ResultFailure<void, Failure>(failure)),
          );
          verify(() => mockRepository.addNote(testNote)).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        const failure = UnexpectedFailure(message: 'Unexpected error');
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNote);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.addNote(testNote)).called(1);
      });
    });
  });
}
