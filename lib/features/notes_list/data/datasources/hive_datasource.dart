import 'package:notes_app/features/notes_list/data/models/note_model.dart';

abstract class HiveDataSource {
  Future<List<NoteModel>> getAllNotes();

  Future<void> addNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> deleteNote(String id);
}
