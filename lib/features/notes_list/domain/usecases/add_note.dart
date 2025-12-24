import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/note_repository.dart';

@injectable
class AddNote implements UseCase<void, Note> {

  const AddNote(this.repository);
  final NoteRepository repository;

  @override
  Future<Result<void, Failure>> call(Note note) async {
    return repository.addNote(note);
  }
}
