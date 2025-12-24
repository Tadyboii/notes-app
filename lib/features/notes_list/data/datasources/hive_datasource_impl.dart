import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/features/notes_list/data/datasources/hive_datasource.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:uuid/uuid.dart';

@Singleton(as: HiveDataSource)
class HiveDataSourceImpl extends HiveDataSource {

  HiveDataSourceImpl({required this.notesBox, required this.uuid});
  final Box<NoteModel> notesBox;
  final Uuid uuid;

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final notes = notesBox.values.toList();
    return notes;
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final id = uuid.v4();
    final noteWithId = note.copyWith(id: id);
    await notesBox.put(id, noteWithId);
  }

  @override
  Future<void> deleteNote(String id) {
    return notesBox.delete(id);
  }

  @override
  Future<void> updateNote(NoteModel note) {
    return notesBox.put(note.id, note);
  }
}
