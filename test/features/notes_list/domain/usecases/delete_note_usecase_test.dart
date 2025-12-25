import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:notes_app/features/notes_list/domain/usecases/delete_note_usecase.dart';

// Mock repository
class MockNoteRepository extends Mock implements INoteRepository {}

void main() {
  late DeleteNoteUseCase useCase;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    useCase = DeleteNoteUseCase(mockRepository);
  });

  group('DeleteNoteUseCase', () {
    group('call', () {
      const testNoteId = '1';

      test(
        'returns success when note is deleted successfully',
        () async {
          // Arrange
          when(
            () => mockRepository.deleteNote(any()),
          ).thenAnswer((_) async => const Result(null));

          // Act
          final result = await useCase.call(testNoteId);

          // Assert
          expect(result, equals(const Result<void, Failure>(null)));
          verify(() => mockRepository.deleteNote(testNoteId)).called(1);
        },
      );

      test('returns ServerFailure when repository call fails', () async {
        // Arrange
        const failure = ServerFailure(message: 'Failed to delete note');
        when(
          () => mockRepository.deleteNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNoteId);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.deleteNote(testNoteId)).called(1);
      });

      test('returns CacheFailure when local storage fails', () async {
        // Arrange
        const failure = CacheFailure(
          message: 'Failed to delete note from cache',
        );
        when(
          () => mockRepository.deleteNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNoteId);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.deleteNote(testNoteId)).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          // Arrange
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.deleteNote(any()),
          ).thenAnswer((_) async => const Result.failure(failure));

          // Act
          final result = await useCase.call(testNoteId);

          // Assert
          expect(
            result,
            equals(const ResultFailure<void, Failure>(failure)),
          );
          verify(() => mockRepository.deleteNote(testNoteId)).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        const failure = UnexpectedFailure(message: 'Unexpected error occurred');
        when(
          () => mockRepository.deleteNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNoteId);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.deleteNote(testNoteId)).called(1);
      });

      test('returns failure when note id does not exist', () async {
        // Arrange
        const failure = ServerFailure(message: 'Note not found');
        when(
          () => mockRepository.deleteNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testNoteId);

        // Assert
        expect(
          result,
          equals(const ResultFailure<void, Failure>(failure)),
        );
        verify(() => mockRepository.deleteNote(testNoteId)).called(1);
      });
    });
  });
}
