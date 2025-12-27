import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:notes_app/features/notes_list/domain/usecases/search_notes_usecase.dart';

// Mock repository
class MockNoteRepository extends Mock implements INoteRepository {}

void main() {
  late SearchNotesUseCase useCase;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    useCase = SearchNotesUseCase(mockRepository);
  });

  group('SearchNotesUseCase', () {
    group('call', () {
      const testQuery = 'test query';
      final testNotes = [
        const Note(
          id: '1',
          title: 'Test Note 1',
          content: 'Content with test query',
        ),
        const Note(
          id: '2',
          title: 'Another Test',
          content: 'More test content',
        ),
      ];

      test(
        'returns success with matching notes when search succeeds',
        () async {
          // Arrange
          when(
            () => mockRepository.searchNotes(testQuery),
          ).thenAnswer((_) async => Result(testNotes));

          // Act
          final result = await useCase.call(testQuery);

          // Assert
          expect(result, equals(Result<List<Note>, Failure>(testNotes)));
          verify(() => mockRepository.searchNotes(testQuery)).called(1);
        },
      );

      test('returns success with empty list when no matches found', () async {
        // Arrange
        when(
          () => mockRepository.searchNotes(testQuery),
        ).thenAnswer((_) async => const Result([]));

        // Act
        final result = await useCase.call(testQuery);

        // Assert
        expect(result, equals(const Result<List<Note>, Failure>([])));
        verify(() => mockRepository.searchNotes(testQuery)).called(1);
      });

      test('returns success with empty list when query is empty', () async {
        // Arrange
        const emptyQuery = '';
        when(
          () => mockRepository.searchNotes(emptyQuery),
        ).thenAnswer((_) async => const Result([]));

        // Act
        final result = await useCase.call(emptyQuery);

        // Assert
        expect(result, equals(const Result<List<Note>, Failure>([])));
        verify(() => mockRepository.searchNotes(emptyQuery)).called(1);
      });

      test('returns ServerFailure when repository call fails', () async {
        // Arrange
        const failure = ServerFailure(message: 'Failed to search notes');
        when(
          () => mockRepository.searchNotes(testQuery),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testQuery);

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.searchNotes(testQuery)).called(1);
      });

      test('returns CacheFailure when local storage fails', () async {
        // Arrange
        const failure = CacheFailure(
          message: 'Failed to search notes from cache',
        );
        when(
          () => mockRepository.searchNotes(testQuery),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testQuery);

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.searchNotes(testQuery)).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          // Arrange
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.searchNotes(testQuery),
          ).thenAnswer((_) async => const Result.failure(failure));

          // Act
          final result = await useCase.call(testQuery);

          // Assert
          expect(
            result,
            equals(const ResultFailure<List<Note>, Failure>(failure)),
          );
          verify(() => mockRepository.searchNotes(testQuery)).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        const failure = UnexpectedFailure(message: 'Unexpected error occurred');
        when(
          () => mockRepository.searchNotes(testQuery),
        ).thenAnswer((_) async => const Result.failure(failure));

        // Act
        final result = await useCase.call(testQuery);

        // Assert
        expect(
          result,
          equals(const ResultFailure<List<Note>, Failure>(failure)),
        );
        verify(() => mockRepository.searchNotes(testQuery)).called(1);
      });
    });
  });
}
