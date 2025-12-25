import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource_impl.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:uuid/uuid.dart';

// Mock classes
class MockBox extends Mock implements Box<NoteModel> {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late NoteLocalDataSourceImpl dataSource;
  late MockBox mockBox;
  late MockUuid mockUuid;

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
    mockBox = MockBox();
    mockUuid = MockUuid();
    dataSource = NoteLocalDataSourceImpl(
      notesBox: mockBox,
      uuid: mockUuid,
    );
  });

  group('NoteLocalDataSourceImpl', () {
    group('getAllNotes', () {
      test('returns list of notes from Hive box', () async {
        // Arrange
        final testNotes = [
          const NoteModel(
            id: '1',
            title: 'Note 1',
            content: 'Content 1',
          ),
          const NoteModel(
            id: '2',
            title: 'Note 2',
            content: 'Content 2',
          ),
        ];
        when(() => mockBox.values).thenReturn(testNotes);

        // Act
        final result = await dataSource.getAllNotes();

        // Assert
        expect(result, equals(testNotes));
        expect(result.length, 2);
        verify(() => mockBox.values).called(1);
      });

      test('returns empty list when no notes exist', () async {
        // Arrange
        when(() => mockBox.values).thenReturn([]);

        // Act
        final result = await dataSource.getAllNotes();

        // Assert
        expect(result, isEmpty);
        verify(() => mockBox.values).called(1);
      });

      test('returns all notes regardless of order', () async {
        // Arrange
        final testNotes = [
          const NoteModel(id: '3', title: 'C', content: 'Content C'),
          const NoteModel(id: '1', title: 'A', content: 'Content A'),
          const NoteModel(id: '2', title: 'B', content: 'Content B'),
        ];
        when(() => mockBox.values).thenReturn(testNotes);

        // Act
        final result = await dataSource.getAllNotes();

        // Assert
        expect(result.length, 3);
        expect(result, equals(testNotes));
        verify(() => mockBox.values).called(1);
      });
    });

    group('addNote', () {
      const testNote = NoteModel(
        id: '',
        title: 'New Note',
        content: 'New Content',
      );

      test('adds note with generated UUID', () async {
        // Arrange
        const generatedId = 'uuid-1234-5678';
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.addNote(testNote);

        // Assert
        final expectedNote = testNote.copyWith(id: generatedId);
        verify(() => mockUuid.v4()).called(1);
        verify(() => mockBox.put(generatedId, expectedNote)).called(1);
      });

      test('uses UUID as key when storing note', () async {
        // Arrange
        const generatedId = 'generated-uuid';
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.addNote(testNote);

        // Assert
        verify(() => mockBox.put(generatedId, any())).called(1);
      });

      test('replaces empty id with generated UUID', () async {
        // Arrange
        const noteWithEmptyId = NoteModel(
          id: '',
          title: 'Title',
          content: 'Content',
        );
        const generatedId = 'new-uuid';
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.addNote(noteWithEmptyId);

        // Assert
        final capturedNote =
            verify(() => mockBox.put(generatedId, captureAny())).captured.single
                as NoteModel;
        expect(capturedNote.id, generatedId);
        expect(capturedNote.title, 'Title');
        expect(capturedNote.content, 'Content');
      });

      test('generates different UUIDs for multiple notes', () async {
        // Arrange
        when(() => mockUuid.v4()).thenReturn('uuid-1');
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.addNote(testNote);

        // Arrange for second call
        when(() => mockUuid.v4()).thenReturn('uuid-2');

        // Act
        await dataSource.addNote(testNote);

        // Assert
        verify(() => mockUuid.v4()).called(2);
        verify(() => mockBox.put('uuid-1', any())).called(1);
        verify(() => mockBox.put('uuid-2', any())).called(1);
      });
    });

    group('updateNote', () {
      const testNote = NoteModel(
        id: '1',
        title: 'Updated Note',
        content: 'Updated Content',
      );

      test('updates note in Hive box using note id as key', () async {
        // Arrange
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.updateNote(testNote);

        // Assert
        verify(() => mockBox.put('1', testNote)).called(1);
      });

      test('uses note id as storage key', () async {
        // Arrange
        const noteWithDifferentId = NoteModel(
          id: '999',
          title: 'Note',
          content: 'Content',
        );
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.updateNote(noteWithDifferentId);

        // Assert
        verify(() => mockBox.put('999', noteWithDifferentId)).called(1);
      });

      test('overwrites existing note with same id', () async {
        // Arrange
        const originalNote = NoteModel(
          id: '1',
          title: 'Original',
          content: 'Original Content',
        );
        const updatedNote = NoteModel(
          id: '1',
          title: 'Updated',
          content: 'Updated Content',
        );
        when(
          () => mockBox.put(any(), any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.updateNote(originalNote);
        await dataSource.updateNote(updatedNote);

        // Assert
        verify(() => mockBox.put('1', originalNote)).called(1);
        verify(() => mockBox.put('1', updatedNote)).called(1);
      });
    });

    group('deleteNote', () {
      test('deletes note from Hive box by id', () async {
        // Arrange
        const noteId = '1';
        when(
          () => mockBox.delete(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.deleteNote(noteId);

        // Assert
        verify(() => mockBox.delete(noteId)).called(1);
      });

      test('deletes correct note when multiple ids exist', () async {
        // Arrange
        const noteIdToDelete = '2';
        when(
          () => mockBox.delete(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.deleteNote(noteIdToDelete);

        // Assert
        verify(() => mockBox.delete('2')).called(1);
        verifyNever(() => mockBox.delete('1'));
        verifyNever(() => mockBox.delete('3'));
      });

      test('can delete multiple notes sequentially', () async {
        // Arrange
        when(
          () => mockBox.delete(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        await dataSource.deleteNote('1');
        await dataSource.deleteNote('2');
        await dataSource.deleteNote('3');

        // Assert
        verify(() => mockBox.delete('1')).called(1);
        verify(() => mockBox.delete('2')).called(1);
        verify(() => mockBox.delete('3')).called(1);
      });
    });
  });
}
