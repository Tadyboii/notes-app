import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/data/datasources/hive_datasource.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/mapper/note_mapper.dart';
import 'package:notes_app/features/notes_list/domain/repositories/note_repository.dart';

@Singleton(as: NoteRepository)
class NoteRepositoryImpl implements NoteRepository {
  final HiveDataSource hiveDatasource;

  NoteRepositoryImpl(this.hiveDatasource);

  @override
  Future<Result<List<Note>, Failure>> getAllNotes() async {
    try {
      final notes = await hiveDatasource.getAllNotes();
      final noteEntities = notes.map((note) => note.toDomain()).toList();
      return Result(noteEntities);
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> addNote(Note note) async {
    try {
      final noteModel = note.toModel();
      await hiveDatasource.addNote(noteModel);
      return Result(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteNote(String id) async {
    try {
      await hiveDatasource.deleteNote(id);
      return Result(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> updateNote(Note note) async {
    try {
      final noteModel = note.toModel();
      await hiveDatasource.updateNote(noteModel);
      return Result(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }
}
