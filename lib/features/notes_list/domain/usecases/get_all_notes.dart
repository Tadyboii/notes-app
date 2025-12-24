import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/note_repository.dart';

@injectable
class GetAllNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  const GetAllNotes(this.repository);

  @override
  Future<Result<List<Note>, Failure>> call(NoParams params) async {
    return await repository.getAllNotes();
  }
}
