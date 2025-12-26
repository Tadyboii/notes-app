import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:notes_app/features/notes_list/domain/usecases/get_all_notes_usecase.dart';

// Mock repository
class MockNoteRepository extends Mock implements INoteRepository {}

void main() {
  late GetAllNotesUseCase useCase;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    useCase = GetAllNotesUseCase(mockRepository);
  });

  group('GetAllNotesUseCase', () {
    group('call', () {
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
        'returns success with list of notes when repository call succeeds',
        () async {
          // Arrange
          when(
            () => mockRepository.getAllNotes(),
          ).thenAnswer((_) async => Result(testNotes));

          // Act
          final result = await useCase.call(const NoParams());

          // Assert
          expect(result, equals(Result<List<Note>, Failure>(testNotes)));
          verify(() => mockRepository.getAllNotes()).called(1);
        },
      );

      test('returns success with empty list when no notes exist', () async {
        // Arrange
        when(
          () => mockRepository.getAllNotes(),
        ).thenAnswer((_) async => const Result([]));

        // Act
        final result = await useCase.call(const NoParams());

        // Assert
        expect(result, equals(const Result<List<Note>, Failure>([])));
        verify(() => mockRepository.getAllNotes()).called(1);
      });

      test('returns ServerFailure when repository call fails', () async {
        // Arrange
        const failure = ServerFailure(message: 'Failed to fetch notes');
        when(
          () => mockRepository.getAllNotes(),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(const NoParams());

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.getAllNotes()).called(1);
      });

      test('returns CacheFailure when local storage fails', () async {
        // Arrange
        const failure = CacheFailure(
          message: 'Failed to load notes from cache',
        );
        when(
          () => mockRepository.getAllNotes(),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(const NoParams());

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.getAllNotes()).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          // Arrange
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.getAllNotes(),
          ).thenAnswer((_) async => const Result.failure(failure));

          // Act
          final result = await useCase.call(const NoParams());

          // Assert
          expect(
            result,
            equals(const ResultFailure<List<Note>, Failure>(failure)),
          );
          verify(() => mockRepository.getAllNotes()).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        const failure = UnexpectedFailure(message: 'Unexpected error occurred');
        when(
          () => mockRepository.getAllNotes(),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(const NoParams());

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.getAllNotes()).called(1);
      });
    });
  });
}
