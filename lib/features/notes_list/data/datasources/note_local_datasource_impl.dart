import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/exceptions.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';

@Singleton(as: NoteLocalDataSource)
class NoteLocalDataSourceImpl extends NoteLocalDataSource {
  NoteLocalDataSourceImpl({required this.notesBox});

  final Box<NoteModel> notesBox;

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final notes = notesBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final notes =
        notesBox.values
            .where(
              (note) =>
                  note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note);
  }

  @override
  Future<void> deleteNote(String id) {
    return notesBox.delete(id);
  }

  @override
  Future<void> updateNote(NoteModel note) {
    return notesBox.put(note.id, note);
  }

  @override
  Future<NoteModel> getNote(String id) async {
    final note = notesBox.get(id);
    if (note == null) {
      throw const CacheException('Note not found');
    }
    return note;
  }
}
