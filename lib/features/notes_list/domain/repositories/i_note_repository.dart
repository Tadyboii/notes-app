import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';

abstract class INoteRepository {
  Future<Result<List<Note>, Failure>> getAllNotes();

  Future<Result<List<Note>, Failure>> searchNotes(String query);

  Future<Result<Note, Failure>> addNote(Note note);

  Future<Result<void, Failure>> updateNote(Note note);

  Future<Result<void, Failure>> deleteNote(String id);
}
