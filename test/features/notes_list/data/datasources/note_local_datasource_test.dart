import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource_impl.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';

class MockBox extends Mock implements Box<NoteModel> {}

void main() {
  late NoteLocalDataSourceImpl dataSource;
  late MockBox mockBox;

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
    dataSource = NoteLocalDataSourceImpl(
      notesBox: mockBox,
    );
  });

  group('NoteLocalDataSourceImpl', () {
    group('getAllNotes', () {
      test('returns list of notes sorted by updatedAt descending', () async {
        final now = DateTime.now();
        final note1 = NoteModel(
          id: '1',
          title: 'Note 1',
          content: 'Content 1',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );
        final note2 = NoteModel(
          id: '2',
          title: 'Note 2',
          content: 'Content 2',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        );

        when(() => mockBox.values).thenReturn([note1, note2]);

        final result = await dataSource.getAllNotes();

        expect(result.length, 2);
        expect(result[0].id, '2');
        expect(result[1].id, '1');
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
      test('adds note using provided id and timestamps', () async {
        final now = DateTime.now();
        final testNote = NoteModel(
          id: 'note-1',
          title: 'New Note',
          content: 'New Content',
          createdAt: now,
          updatedAt: now,
        );

        when(
          () => mockBox.put(any<String>(), any<NoteModel>()),
        ).thenAnswer((_) async {});

        await dataSource.addNote(testNote);

        verify(() => mockBox.put(testNote.id, testNote)).called(1);
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

        when(
          () => mockBox.put(any<String>(), any<NoteModel>()),
        ).thenAnswer((_) async {});

        await dataSource.updateNote(testNote);

        verify(() => mockBox.put(testNote.id, testNote)).called(1);
      });
    });

    group('deleteNote', () {
      test('deletes note from Hive box by id', () async {
        const noteId = '1';
        when(() => mockBox.delete(any<String>())).thenAnswer((_) async {});

        await dataSource.deleteNote(noteId);

        verify(() => mockBox.delete(noteId)).called(1);
      });
    });

    group('searchNotes', () {
      test(
        'returns list of notes matching query sorted by updatedAt descending',
        () async {
          final now = DateTime.now();
          final note1 = NoteModel(
            id: '1',
            title: 'Shopping List',
            content: 'Buy milk and eggs',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 1)),
          );
          final note2 = NoteModel(
            id: '2',
            title: 'Work Tasks',
            content: 'Finish the report',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now,
          );

          when(() => mockBox.values).thenReturn([note1, note2]);

          final result = await dataSource.searchNotes('milk');

          expect(result.length, 1);
          expect(result[0].id, '1');
          verify(() => mockBox.values).called(1);
        },
      );

      test('returns empty list when no notes match query', () async {
        final now = DateTime.now();
        final note1 = NoteModel(
          id: '1',
          title: 'Shopping List',
          content: 'Buy milk and eggs',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );
        final note2 = NoteModel(
          id: '2',
          title: 'Work Tasks',
          content: 'Finish the report',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        );

        when(() => mockBox.values).thenReturn([note1, note2]);

        final result = await dataSource.searchNotes('gym');

        expect(result, isEmpty);
        verify(() => mockBox.values).called(1);
      });
    });
  });
}
