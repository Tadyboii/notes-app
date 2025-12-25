import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';

void main() {
  final now = DateTime.now();

  group('NoteModel', () {
    final testNoteModel = NoteModel(
      id: '1',
      title: 'Test Note',
      content: 'Test Content',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates NoteModel from valid JSON', () {
        final json = {
          'id': '1',
          'title': 'Test Note',
          'content': 'Test Content',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final result = NoteModel.fromJson(json);

        expect(result.id, '1');
        expect(result.title, 'Test Note');
        expect(result.content, 'Test Content');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });
    });

    group('toJson', () {
      test('converts NoteModel to JSON', () {
        final result = testNoteModel.toJson();

        expect(result['id'], '1');
        expect(result['title'], 'Test Note');
        expect(result['content'], 'Test Content');
        expect(DateTime.parse(result['createdAt'] as String), now);
        expect(DateTime.parse(result['updatedAt'] as String), now);
      });
    });

    group('JSON serialization round-trip', () {
      test('maintains data integrity through serialization cycle', () {
        final json = testNoteModel.toJson();
        final deserialized = NoteModel.fromJson(json);

        expect(deserialized, equals(testNoteModel));
      });
    });

    group('equality', () {
      test('two NoteModels with same values are equal', () {
        final model2 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
          createdAt: now,
          updatedAt: now,
        );

        expect(testNoteModel, equals(model2));
        expect(testNoteModel.hashCode, equals(model2.hashCode));
      });
    });

    group('copyWith', () {
      test('creates copy with updated id', () {
        final result = testNoteModel.copyWith(id: '999');
        expect(result.id, '999');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('creates copy with updated timestamps', () {
        final newTime = now.add(const Duration(days: 1));
        final result = testNoteModel.copyWith(
          createdAt: newTime,
          updatedAt: newTime,
        );

        expect(result.createdAt, newTime);
        expect(result.updatedAt, newTime);
      });
    });
  });
}
