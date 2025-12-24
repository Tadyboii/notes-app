import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/note_repository.dart';

@injectable
class UpdateNote implements UseCase<void, Note> {
  final NoteRepository repository;

  const UpdateNote(this.repository);

  @override
  Future<Result<void, Failure>> call(Note note) async {
    return await repository.updateNote(note);
  }
}
