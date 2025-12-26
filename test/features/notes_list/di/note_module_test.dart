import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:notes_app/features/notes_list/di/note_module.dart';

void main() {
  group('NoteModule', () {
    late NoteModule noteModule;
    late Directory tempDir;

    setUpAll(() async {
      // Use a temporary directory for Hive (test-safe)
      tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NoteModelAdapter());
      }
    });

    setUp(() {
      noteModule = _NoteModule();
    });

    tearDown(() async {
      if (Hive.isBoxOpen('notesBox')) {
        final box = Hive.box<NoteModel>('notesBox');
        await box.clear();
        await box.close();
      }
      await Hive.deleteBoxFromDisk('notesBox');
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('notesBox should return an open Box<NoteModel>', () async {
      final box = await noteModule.notesBox;

      expect(box, isA<Box<NoteModel>>());
      expect(box.isOpen, true);
    });

    test(
      'notesBox should return the same instance on multiple calls',
          () async {
        final box1 = await noteModule.notesBox;
        final box2 = await noteModule.notesBox;

        expect(identical(box1, box2), true);
      },
    );

    test('notesBox should be empty when first opened', () async {
      final box = await noteModule.notesBox;

      expect(box.isEmpty, true);
      expect(box.length, 0);
    });

    test('notesBox should store and retrieve NoteModel with dates', () async {
      final box = await noteModule.notesBox;
      final now = DateTime.now();
      final testNote = NoteModel(
        id: '1',
        title: 'Test Title',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      await box.put('1', testNote);

      final storedNote = box.get('1');
      expect(box.length, 1);
      expect(storedNote?.id, '1');
      expect(storedNote?.title, 'Test Title');
      expect(storedNote?.content, 'Test Content');
      expect(storedNote?.createdAt.isAtSameMomentAs(now), true);
      expect(storedNote?.updatedAt.isAtSameMomentAs(now), true);
    });

    test('notesBox should handle multiple notes', () async {
      final box = await noteModule.notesBox;
      final now = DateTime.now();
      final note1 = NoteModel(
        id: '1',
        title: 'Title 1',
        content: 'Content 1',
        createdAt: now,
        updatedAt: now,
      );
      final note2 = NoteModel(
        id: '2',
        title: 'Title 2',
        content: 'Content 2',
        createdAt: now,
        updatedAt: now,
      );
      final note3 = NoteModel(
        id: '3',
        title: 'Title 3',
        content: 'Content 3',
        createdAt: now,
        updatedAt: now,
      );

      await box.put('1', note1);
      await box.put('2', note2);
      await box.put('3', note3);

      expect(box.length, 3);
      expect(box.values.length, 3);
    });

    test('notesBox should delete notes', () async {
      final box = await noteModule.notesBox;
      final now = DateTime.now();
      final testNote = NoteModel(
        id: '1',
        title: 'Test Title',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      await box.put('1', testNote);
      await box.delete('1');

      expect(box.isEmpty, true);
      expect(box.get('1'), null);
    });

    test('notesBox should clear all notes', () async {
      final box = await noteModule.notesBox;
      final now = DateTime.now();
      final note1 = NoteModel(
        id: '1',
        title: 'Title 1',
        content: 'Content 1',
        createdAt: now,
        updatedAt: now,
      );
      final note2 = NoteModel(
        id: '2',
        title: 'Title 2',
        content: 'Content 2',
        createdAt: now,
        updatedAt: now,
      );

      await box.put('1', note1);
      await box.put('2', note2);

      await box.clear();

      expect(box.isEmpty, true);
    });
  });
}

// Concrete implementation for testing
class _NoteModule extends NoteModule {
  @override
  Future<Box<NoteModel>> get notesBox => Hive.openBox<NoteModel>('notesBox');
}
