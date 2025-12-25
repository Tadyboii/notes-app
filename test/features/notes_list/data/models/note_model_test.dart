import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';

void main() {
  group('NoteModel', () {
    const testNoteModel = NoteModel(
      id: '1',
      title: 'Test Note',
      content: 'Test Content',
    );

    group('fromJson', () {
      test('creates NoteModel from valid JSON', () {
        // Arrange
        final json = {
          'id': '1',
          'title': 'Test Note',
          'content': 'Test Content',
        };

        // Act
        final result = NoteModel.fromJson(json);

        // Assert
        expect(result.id, '1');
        expect(result.title, 'Test Note');
        expect(result.content, 'Test Content');
      });

      test('creates NoteModel with empty strings', () {
        // Arrange
        final json = {
          'id': '',
          'title': '',
          'content': '',
        };

        // Act
        final result = NoteModel.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.title, '');
        expect(result.content, '');
      });

      test('creates NoteModel with special characters', () {
        // Arrange
        final json = {
          'id': '123',
          'title': 'Note with émojis 🎉',
          'content': 'Content with\nnew lines\nand "quotes"',
        };

        // Act
        final result = NoteModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.title, 'Note with émojis 🎉');
        expect(result.content, 'Content with\nnew lines\nand "quotes"');
      });
    });

    group('toJson', () {
      test('converts NoteModel to JSON', () {
        // Arrange
        const model = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], '1');
        expect(result['title'], 'Test Note');
        expect(result['content'], 'Test Content');
      });

      test('converts NoteModel with empty strings to JSON', () {
        // Arrange
        const model = NoteModel(
          id: '',
          title: '',
          content: '',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], '');
        expect(result['title'], '');
        expect(result['content'], '');
      });

      test('converts NoteModel with special characters to JSON', () {
        // Arrange
        const model = NoteModel(
          id: '123',
          title: 'Note with émojis 🎉',
          content: 'Content with\nnew lines',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], '123');
        expect(result['title'], 'Note with émojis 🎉');
        expect(result['content'], 'Content with\nnew lines');
      });
    });

    group('JSON serialization round-trip', () {
      test('maintains data integrity through serialization cycle', () {
        // Arrange
        const original = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
        );

        // Act
        final json = original.toJson();
        final deserialized = NoteModel.fromJson(json);

        // Assert
        expect(deserialized, equals(original));
        expect(deserialized.id, original.id);
        expect(deserialized.title, original.title);
        expect(deserialized.content, original.content);
      });

      test('maintains special characters through serialization cycle', () {
        // Arrange
        const original = NoteModel(
          id: '999',
          title: 'Special: @#\$%^&*()',
          content: 'Line1\nLine2\nLine3',
        );

        // Act
        final json = original.toJson();
        final deserialized = NoteModel.fromJson(json);

        // Assert
        expect(deserialized, equals(original));
      });
    });

    group('equality', () {
      test('two NoteModels with same values are equal', () {
        // Arrange
        const model1 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
        );
        const model2 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('two NoteModels with different ids are not equal', () {
        // Arrange
        const model1 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Test Content',
        );
        const model2 = NoteModel(
          id: '2',
          title: 'Test Note',
          content: 'Test Content',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });

      test('two NoteModels with different titles are not equal', () {
        // Arrange
        const model1 = NoteModel(
          id: '1',
          title: 'Test Note 1',
          content: 'Test Content',
        );
        const model2 = NoteModel(
          id: '1',
          title: 'Test Note 2',
          content: 'Test Content',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });

      test('two NoteModels with different content are not equal', () {
        // Arrange
        const model1 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Content 1',
        );
        const model2 = NoteModel(
          id: '1',
          title: 'Test Note',
          content: 'Content 2',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated id', () {
        // Arrange & Act
        final result = testNoteModel.copyWith(id: '999');

        // Assert
        expect(result.id, '999');
        expect(result.title, 'Test Note');
        expect(result.content, 'Test Content');
      });

      test('creates copy with updated title', () {
        // Arrange & Act
        final result = testNoteModel.copyWith(title: 'New Title');

        // Assert
        expect(result.id, '1');
        expect(result.title, 'New Title');
        expect(result.content, 'Test Content');
      });

      test('creates copy with updated content', () {
        // Arrange & Act
        final result = testNoteModel.copyWith(content: 'New Content');

        // Assert
        expect(result.id, '1');
        expect(result.title, 'Test Note');
        expect(result.content, 'New Content');
      });

      test('creates copy with multiple updated fields', () {
        // Arrange & Act
        final result = testNoteModel.copyWith(
          id: '999',
          title: 'New Title',
          content: 'New Content',
        );

        // Assert
        expect(result.id, '999');
        expect(result.title, 'New Title');
        expect(result.content, 'New Content');
      });

      test('copyWith returns new instance', () {
        // Arrange & Act
        final result = testNoteModel.copyWith(title: 'New Title');

        // Assert
        expect(result, isNot(same(testNoteModel)));
        expect(result, isNot(equals(testNoteModel)));
      });
    });
  });
}