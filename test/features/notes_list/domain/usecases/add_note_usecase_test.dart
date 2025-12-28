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
    // Fallback value required by mocktail for Note typed any()
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
      const inputNote = Note(
        title: 'Test Note',
        content: 'Test Content',
      );

      final returnedNote = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('returns success when note is added successfully', () async {
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => Result<Note, Failure>(returnedNote));

        final result = await useCase.call(inputNote);

        expect(result, equals(Result<Note, Failure>(returnedNote)));
        verify(() => mockRepository.addNote(inputNote)).called(1);
      });

      test('returns success when adding note with empty content', () async {
        const noteWithEmptyContent = Note(
          title: 'Title Only',
          content: '',
        );

        final returned = Note(
          id: '2',
          title: 'Title Only',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => Result<Note, Failure>(returned));

        final result = await useCase.call(noteWithEmptyContent);

        expect(result, equals(Result<Note, Failure>(returned)));
        verify(() => mockRepository.addNote(noteWithEmptyContent)).called(1);
      });

      test('returns success when adding note with empty title', () async {
        const noteWithEmptyTitle = Note(
          title: '',
          content: 'Content Only',
        );

        final returned = Note(
          id: '3',
          title: '',
          content: 'Content Only',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => Result<Note, Failure>(returned));

        final result = await useCase.call(noteWithEmptyTitle);

        expect(result, equals(Result<Note, Failure>(returned)));
        verify(() => mockRepository.addNote(noteWithEmptyTitle)).called(1);
      });

      test(
        'returns ServerFailure when repository returns ServerFailure',
        () async {
          const failure = ServerFailure(message: 'Failed to add note');
          when(
            () => mockRepository.addNote(any()),
          ).thenAnswer((_) async => const Result.failure(failure));

          final result = await useCase.call(inputNote);

          expect(result, equals(const ResultFailure<Note, Failure>(failure)));
          verify(() => mockRepository.addNote(inputNote)).called(1);
        },
      );

      test('returns CacheFailure when local storage fails', () async {
        const failure = CacheFailure(message: 'Failed to save note locally');
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        final result = await useCase.call(inputNote);

        expect(result, equals(const ResultFailure<Note, Failure>(failure)));
        verify(() => mockRepository.addNote(inputNote)).called(1);
      });

      test(
        'returns NetworkFailure when there is no internet connection',
        () async {
          const failure = NetworkFailure(message: 'No internet connection');
          when(
            () => mockRepository.addNote(any()),
          ).thenAnswer((_) async => const Result.failure(failure));

          final result = await useCase.call(inputNote);

          expect(result, equals(const ResultFailure<Note, Failure>(failure)));
          verify(() => mockRepository.addNote(inputNote)).called(1);
        },
      );

      test('returns UnexpectedFailure when unexpected error occurs', () async {
        const failure = UnexpectedFailure(message: 'Unexpected error');
        when(
          () => mockRepository.addNote(any()),
        ).thenAnswer((_) async => const Result.failure(failure));

        final result = await useCase.call(inputNote);

        expect(result, equals(const ResultFailure<Note, Failure>(failure)));
        verify(() => mockRepository.addNote(inputNote)).called(1);
      });
    });
  });
}
