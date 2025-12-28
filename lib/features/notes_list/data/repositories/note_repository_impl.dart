import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/exceptions.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/mapper/note_mapper.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';
import 'package:uuid/uuid.dart';

@Singleton(as: INoteRepository)
class NoteRepositoryImpl implements INoteRepository {
  NoteRepositoryImpl(this.noteLocalDatasource, this.uuid);

  final NoteLocalDataSource noteLocalDatasource;
  final Uuid uuid;

  @override
  Future<Result<List<Note>, Failure>> getAllNotes() async {
    try {
      final notes = await noteLocalDatasource.getAllNotes();
      final noteEntities = notes.map((note) => note.toDomain()).toList();
      return Result(noteEntities);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Note>, Failure>> searchNotes(String query) async {
    try {
      final notes = await noteLocalDatasource.searchNotes(query);
      final noteEntities = notes.map((note) => note.toDomain()).toList();
      return Result(noteEntities);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Note, Failure>> addNote(Note note) async {
    try {
      final noteModel = NoteModel(
        id: uuid.v4(),
        title: note.title,
        content: note.content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await noteLocalDatasource.addNote(noteModel);
      return Result(noteModel.toDomain());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteNote(String id) async {
    try {
      await noteLocalDatasource.deleteNote(id);
      return const Result(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> updateNote(Note updatedNote) async {
    try {
      final oldNote = await noteLocalDatasource.getNote(updatedNote.id!);
      final newNote = NoteModel(
        id: oldNote.id,
        title: updatedNote.title,
        content: updatedNote.content,
        createdAt: oldNote.createdAt,
        updatedAt: DateTime.now(),
      );
      await noteLocalDatasource.updateNote(newNote);
      return const Result(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
