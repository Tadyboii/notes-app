import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/exceptions.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/features/notes_list/data/datasources/note_local_datasource.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/mapper/note_mapper.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';

@Singleton(as: INoteRepository)
class NoteRepositoryImpl implements INoteRepository {
  NoteRepositoryImpl(this.noteLocalDatasource);

  final NoteLocalDataSource noteLocalDatasource;

  @override
  Future<Result<List<Note>, Failure>> getAllNotes() async {
    try {
      final notes = await noteLocalDatasource.getAllNotes();
      final noteEntities = notes.map((note) => note.toDomain()).toList();
      return Result(noteEntities);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.toString(), statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }


  @override
  Future<Result<void, Failure>> addNote(Note note) async {
    try {
      final noteModel = note.toModel();
      await noteLocalDatasource.addNote(noteModel);
      return const Result(null);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.toString(), statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteNote(String id) async {
    try {
      await noteLocalDatasource.deleteNote(id);
      return const Result(null);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.toString(), statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> updateNote(Note note) async {
    try {
      final noteModel = note.toModel();
      await noteLocalDatasource.updateNote(noteModel);
      return const Result(null);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.toString(), statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      return Result.failure(UnexpectedFailure(message: e.toString()));
    }
  }
}
