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
    registerFallbackValue(
      NoteModel(
        id: '',
        title: '',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        final now = DateTime.now();
        final testNotes = [
          NoteModel(
            id: '1',
            title: 'Note 1',
            content: 'Content 1',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          NoteModel(
            id: '2',
            title: 'Note 2',
            content: 'Content 2',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now,
          ),
        ];
        when(() => mockBox.values).thenReturn(testNotes);

        final result = await dataSource.getAllNotes();

        expect(result, equals(testNotes));
        expect(result.length, 2);
        verify(() => mockBox.values).called(1);
      });

      test('returns empty list when no notes exist', () async {
        when(() => mockBox.values).thenReturn([]);

        final result = await dataSource.getAllNotes();

        expect(result, isEmpty);
        verify(() => mockBox.values).called(1);
      });
    });

    group('addNote', () {
      test('adds note with generated UUID and timestamps', () async {
        final now = DateTime.now();
        const generatedId = 'uuid-1234';
        final testNote = NoteModel(
          id: '',
          title: 'New Note',
          content: 'New Content',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.addNote(testNote);

        final capturedNote =
        verify(() => mockBox.put(generatedId, captureAny())).captured.single
        as NoteModel;

        expect(capturedNote.id, generatedId);
        expect(capturedNote.createdAt, now);
        expect(capturedNote.updatedAt, now);
      });
    });

    group('updateNote', () {
      test('updates note in Hive box using note id and updatedAt', () async {
        final now = DateTime.now();
        final testNote = NoteModel(
          id: '1',
          title: 'Updated Note',
          content: 'Updated Content',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        );

        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.updateNote(testNote);

        verify(() => mockBox.put('1', testNote)).called(1);
      });
    });

    group('deleteNote', () {
      test('deletes note from Hive box by id', () async {
        const noteId = '1';
        when(() => mockBox.delete(any())).thenAnswer((_) async {});

        await dataSource.deleteNote(noteId);

        verify(() => mockBox.delete(noteId)).called(1);
      });
    });
  });
}
